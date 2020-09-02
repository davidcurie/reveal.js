#!/bin/bash
#####################################################################
# Author: David Curie
# Descrigitption: This shell script populates a folder of reveal.js decks with multiple files that have an identical format (i.e. all the same <stylesheet> and <script> settings) based on a pre-formatted master template and body slides from a specified search. Upon execution,the requested body slides are spliced into a copy of the master template and the resultant new.html file is given an appropriate name to match the content parent.html, overwriting any files that already exist with the pre-determined name new.html. Any files not matching the naming structure of the search criteria remain untouched.
#
# Expectations:
# - Master template is a modified reveal.js .html file with the following variables to be replaced
#     ${full_file} // Location of current file being overwritten
#     ${base} // Root name of file (for use in menu)
#     ${Parent_File} // Location of source of parent content
#     ${Append_CSS} // Extra stylesheets to include in <head> (if plugin)
#     ${Replace_Title} // Inside <title> tag
#     ${Replace_Content} // Slide content inside <div class="slides">
#     ${Append_Script} // Extra scripts outside <div class="reveal">
#     ${Append_Init} // Extra options in Reveal.initialize({ })
#     ${Append_Plugin} // Extra plugin labels
#     ${Append_Depend} // Extra dependencies
#
# - Files with content to which the template should be applied reside in a content/ directory with a filename that ends in -x.html. This restriction can be changed by modifying the $search variable. Files that match the $search condition will be spliced into a file with the same name it had in the content/ directory but without the trailing -x. (i.e. content/File1x.html will create/overwrite File1.html in the current directory.) This naming convention can also be changed by adjusting the rename () function.
# - content/parentx.html contains only slide material that is nested in <section> tags, but the head of the file contains commented lines with named variables to override/append to the default template variables or to initiate dynamic builds. The following convention is used to pick out extra optional variables at the start of a line. If no variable is supplied, its default is null. The order of variables is irrelevant.
# === parentx.html ==========================
# 1<!--
# 2  is_multi (optional, set if want to keep multiplex dependencies)
# 3  has_spreadsheet (set to keep spreadsheet dependencies)
# 4  title="Interesting title with spaces"
# 5  css="<link rel='stylesheet' href='../path' >"
# 6  script="<script src='../path'></script>"
# 7  init="setting: { option: value, option: value},"
# 8  depend="{ src: "../path", option: value},"
# 9  secret="" (optional override for multiplex)
# 10 socket_id="" (optional override for multiplex)
# 11 socket_url="" (optional override for multiplex)
# 12-->
# 13<section> <!-- Begin Slides -->
#       ...
#   </section> <!-- Final Slide -->
# =================================================
#
# Uncomment lines that end with # Shell Debug to see explicit
#    variables in the terminal on execution
#
# Last edited: 2020 Aug 15
#
#
#####################################################################




# Store default internal field separator
Field_Separator=$IFS
# Change IFS to separate lists by , instead of default whitespace
# (Allows filenames with spaces to be parsed correctly)
IFS=,

# Specify where to look for the master slide template relative to this file
master='build_template.html'

# Specify the search criteria relative to current directory
# Default: Assume Labs are located in content/Lab*x.html
# If altered, update rename() function accordingly
search='content/Lab*x.html' # all files in content/ that start with Lab and end with x.html

# ALTERNATE SUGGESTIONS (relative to current directory)
# search="*x.html" # all files that end with x.html
# search='content/*.html' # all files in content/ that end in .html
# search='File?.html' # all names that start with File and have exactly one char wildcard (?)
#   e.g. File1.html works but not File10.html or File_1.html



# FUNCTIONS#########################################################

# Desired formula for converting old_file.html to new_file.html
# > sed -options 's/find/replace'
#    find = content/ --> use literal '\content\/' for \ protection
# > Feed first preceding argument ($1) into sed (input | sed)
rename () {
    echo "$1" | sed -e 's/\content\///' -e 's/x//1' # Strip away 'content/' and trailing -x in input filename
}

# Convert (aka 'escape') all instances of '/' to '\/' for future sed use
# Use: make_nice 'complicated/file/path'
#
# > sed -e[xpression] "s[ubstitue]/find/replace/g[lobal]"
#    find = / --> use literal '\/' for '/'
#    replace = \/ --> use '\\' for '\' and '\/' for '/'
#    g --> replace ALL instances instead of [default] first instance on a line
# > Feed input ($1) into sed: (filename | sed )
make_nice () {
    echo "$1" | sed -e 's/\//\\\//g'
}

# Get variable string from file.
# Use: get_var $variable $file
# ! Assumes variables are listed at the top of the file, start at the
#   beginning of the line, and are written in the form: variable="string"
# > sed -n "/^find/p" : print line that starts with 'find'
#           /^find/q  : quit after matching line that starts with 'find'
#       /<section>/q : quit when body starts if not found already
# > cut -d \ -f2 : cut string into fields using " as delimiter
#   variable strings are of form pre="value"post, so field 2 contains value
get_var () {
    make_nice "$(sed -n "/^$1/p; /^$1/q; /<section>/q;" "$2" | cut -d \" -f2)"
}

# Check to see if word starts a line in a file.
# Use: check_if $word $file
# > sed "/^find/p" to look for find at start of a line
#        /match/q : quit after match
# > If resulting string is non-empty, set to true. If no match, set false.
check_if () {
    if [ "$(sed -n "/^$1/p; /^$1/q; /<section>/q;" "$2")" ]
    then
        echo true
    else
        echo false
    fi
}


touch build.log # Initiate a new log instance
cat  build.log > "build_log.tmp" # Store existing log in temporary location
echo "==================================================" > build.log
echo "New log generated on: `date`" >> build.log
echo "" >> build.log
echo "Template: $master" >> build.log
echo "Searching files that match [$search]" >> build.log
{ echo -n "Extract and rename: "$search" -> " & rename "$search"; } >> build.log

# Cycle through all files that match the search criteria. For each file, re-populate the presentation from scratch
for f in ${search}; do
#for f in 'content/Lab0x.html'; do

    # GATHER FILENAME VARIABLES #####################################
    
    # Display [current] parent filename
    # echo "  Looking at file    : $f" # Shell Debug
    
    # make sed-compatible parent filename
    parent=$(make_nice "$f")
    
    # Get core name of file at parent path but without extension
    # find = .ext --> use '\.' for '.';
    #    [ ] for "match whatever is between these"
    #    '^' for 'the start of line'
    #    '.' for 'exactly one'
    #    '*' for 'match 0 or more occurence of previous char/arg'
    #    '$' for 'end of the line' (i.e. for the rest of the string)
    #    \.[^.]*$ for "the subset of text that exactly matches the form of '.end_of_line' but not '.mid.end.line' "
    # replace = '' = (nothing, delete what was found)
    base=$(rename "$f" | sed -e 's/\.[^.]*$//')




    # GATHER PARENT FILE VARIABLES ##################################

    echo " < Extracting variables from $f" >> build.log

    # Get title of slide
    title="$(get_var 'title' "$f")"
    
    # Get extra stylesheets if requested
    css="$(get_var 'css' "$f")"
    if [ "$css" ] # If css present (non-empty), append comment
    then
        css=$(echo "$css"" <!-- Inserted from $parent -->")
    fi
    
    # Get extra scripts to insert
    script="$(get_var 'script' "$f")"
    if [ "$script" ] # If script present (non-empty), append comment
    then
        script=$(echo "$script"" <!-- Inserted from $parent -->")
    fi

    # Get extra initialization parameters
    # init="menu: {slideNumber: true,}" # Example
    init="$(get_var 'init' "$f")"
    if [ "$init" ] # If init present (non-empty), append comment
    then
        init=$(echo "$init"", \/\/ Inserted from $parent")
    fi

    # Get requested plugins
    plugin="$(get_var 'plugin' "$f")"
    if [ "$plugin" ] # If plugin present (non-empty), append comment
    then
        plugin=$(echo "$plugin"", \/\/ Inserted from $parent")
    fi

    # Get extra dependencies (5th line)
    # depend="{ src: '../../example', async: true }" # Example
    depend="$(get_var 'depend' "$f")"
    if [ "$depend" ] # If depend present (non-empty), append comment
    then
        depend=$(echo "$depend"", \/\/ Inserted from $parent")
    fi

    # Check to see if multiplexing is specified in parent (default=false)
    is_multi="$(check_if 'is_multi' "$f")"

    # Check to see if parent makes use of spreadsheet (default=false)
    has_spreadsheet="$(check_if 'has_spreadsheet' "$f")"
    
    



    # LOGICAL CONSTRUCTION OF STAGING TEMPLATE ######################
    
    # Bring in clean template
    echo "     Staging $base template...loading new template" >> build.log
    cat "$master" > "staging_${base}.tmp"
    
    # Create a filename array to write to
    write="${base}.html"
    
    # Default: remove multiplex dependencies unless explicit use by parent
    if [ "$is_multi" == true ]
    then # If multiplexing, also create a _master.html. Then append variables
        echo "   ! Multiplexing detected...gathering more variables" >> build.log
        write+=",${base}_master.html" # add to list of files to create
        # Gather variables
        secret=$(make_nice "$(get_var 'secret' "$f")")
        socket_id=$(make_nice "$(get_var 'socket_id' "$f")")
        socket_url=$(make_nice "$(get_var 'socket_url' "$f")")
        # Remove only selector handles from template
        sed -i '' "/\if_multi/d" "staging_${base}.tmp"
        sed -i '' "/\fi_multi/d" "staging_${base}.tmp"
        
    else # If no multiplexing, delete all relevant lines from template
       echo "     Multiplex not detected...removing dependencies" >> build.log
       # sed '/pattern1/,/pattern2/{do this;}' : do this between matching pattern
       # ^text$: pattern is (new line + text + end of line)
       # /^/d : for each match of ^ (new line), delete the line
       sed -i '' '/^if_multi$/,/^fi_multi$/{ /^/d;}' "staging_${base}.tmp"
    fi
        
    # Default: remove spreadsheet dependencies unless explicit use by parent
    if [ "$has_spreadsheet" == true ]
    then # If spreadsheet, do nothing (dependencies already loaded)
        echo "   ! Spreadsheet detected...ensuring dependencies" >> build.log
        # Remove only selector handles from template
        sed -i '' "/\if_spreadsheet/d" "staging_${base}.tmp"
        sed -i '' "/\fi_spreadsheet/d" "staging_${base}.tmp"

    else # If no spreadsheet, delete all relevant lines from template
        echo "     Spreadsheet not detected...removing dependencies" >> build.log
        # delete all lines between pattern1 and pattern2
        sed -i '' '/^if_spreadsheet$/,/^fi_spreadsheet$/{ /^/d;}' "staging_${base}.tmp"
    fi
    
    
    
    
    # ASSEMBLE TEMPLATE WITH COMMON VARIABLES  ######################
    
    echo "     Applying common variables to $base" >> build.log
    
    # Check the status of all variables from parent in terminal
    # Uncomment the variable you want to inspect
#    echo "        base         : $base" # Shell Debug
#    echo "        Parent_File  : $f" # Shell Debug
#    echo "        is_multi     : $is_multi" # Shell Debug
#    echo "        has_spread   : $has_spreadsheet" # Shell Debug
#    echo "        Append_CSS   : $css" # Shell Debug
#    echo "        Replace_Title: $title" # Shell Debug
#    echo "        Append_Script: $script" # Shell Debug
#    echo "        Append_Init  : $init" # Shell Debug
#    echo "        Append_Plugin: $plugin" # Shell Debug
#    echo "        Append_Depend: $depend" # Shell Debug
#    echo "        secret       : $secret" # Shell Debug
#    echo "        socket_id    : $socket_id" # Shell Debug
#    echo "        socket_url   : $socket_url" # Shell Debug
    


    # Replace variables (i)n place
    #   sed -i '.ext' "command1; command2" file
    #     '.ext' = desired backup extension (none b/c temp file)
    #     \ at end of line to continue expression on next line
    sed -i '' "s/\${Parent_File}/${parent}/;  \
        s/\${base}/${base}/;                  \
        s/\${Append_CSS}/${css}/;             \
        s/\${Replace_Title}/${title}/;        \
        s/\${Append_Script}/${script}/;       \
        s/\${Append_Init}/${init}/;           \
        s/\${Append_Plugin}/${plugin}/;       \
        s/\${Append_Depend}/${depend}/;       \
        s/\${socket_id}/${socket_id}/;        \
        s/\${socket_url}/${socket_url}/"      \
        "staging_${base}.tmp" # file to overwrite


    # Start generation process for base (client) and/or master slides
    #    $write is a filename array with files separated by spaces.
    #    Spaces in parent filenames will create incorrect filenames.
    #    If not multiplexing, you can fix this by using "$write", but then
    #    {base}.html and {base}_master.html will be one file
    for b in ${write}; do

        # Get current basefile iteration
        # echo "    Entering file    : $b" # Shell Debug
        # Bring in common template from above to reset on each iteration
        cat "staging_${base}.tmp" > "staging2_${b}.tmp"




        # GET UNIQUE VARIABLES TO THIS FILE ########################

        # Find location of current file relative to server directory
        # > Print working directory : echo $(pwd)
        # > strip away everything before selected directory (decks) using sed
        #    find = '.*' = everything up to,including (match) - () escaped with \
        #    replace = \1 = what is stored in () i.e. first capture group
        # > Concat both steps above into pipeline with ( input | sed )
        # > Re-evaluate with echo $(pipeline) and append rest of filename "/$b"
        #   Store result in variable: full_file
#        full_file=$(echo $(echo $(pwd) | sed 's/.*\(decks\)/\1/g')"/$b")
        #
        # Alternate method
        #   `pwd` = print working directory (built-in function)
        #   ${pwd} = expanded result of `pwd` function
        # > PWD = system variable shortcut to above when used inside ${}
        #   ${HOME} = User home directory (e.g Users/David)
        # > (1/2/3/4)##(1/2) = /3/4
        # > make_nice for sed compatibility
        full_file=$(make_nice "$(echo ${PWD##${HOME}})/$b")
        
        
        
        
        # APPLY CONDITIONAL CHANGES TO TEMPLATE #####################
        
        # Adjust multiplexing dependencies
        if [ "$is_multi" == true ]
        then # If multiplexing, adjust variables for client or master
            echo "   .   Ammending template for $b" >> build.log
        
            # Check if current file is _master.html
            if [ "$b" = "$base"_master.html ]
            then # If master: remove client.js, set variables
                echo "   .   Adjusting format for master" >> build.log
                
                # Insert secret key
                sed -i '' "s/\${secret}/${secret}/" "staging2_${b}.tmp"
                
                # Remove entire line that contains client.js
                sed -i '' "/\client.js/d" "staging2_${b}.tmp"
                 
            else # If not master: remove master.js, secret=null
                echo "   .   Adjusting format for client" >> build.log
                
                # Don't insert secret key (=null)
                sed -i '' "s/\${secret}/null/" "staging2_${b}.tmp"
                
                # Remove entire line that contains master.js
                sed -i '' "/\master.js/d" "staging2_${b}.tmp"
                
            fi # end client/master check
        fi # end multiplexing variables
                
        
        
        # INSERT REMAINING VARIABLES ################################
        
        # Inspect new variables in this iteration
        # echo "        full_file    : $full_file" # Shell Debug
        
        # Append filepath of current build at top of html
        sed -i '' "s/\${full_file}/${full_file}/" "staging2_${b}.tmp"

        # If current file is _master.html: make link to content (reduce filesize)
        #    > Requires /plugin/external/external.js
        if [ "$b" = "$base"_master.html ]
        then
            # echo "        body_status  : link" # Shell Debug
            #
            #
            sed -i '' "s/\${Replace_Content}/\Linked/"  "staging2_${b}.tmp"
            #
            #
            
        else # If not _master.html: paste in content
            # echo "        body_status  : paste" # Shell Debug
            
            # Copy contents of parent file into temporary staging file for non-destructive re-formating
            #   insert 4 tabs (16 spaces) at each line
            sed -e "s/^/                /"  "$f" > "staging_${base}_content.tmp"
            
            # replace: '/find/r replace_with' original_file
            sed -i '' "/\${Replace_Content}/r staging_${base}_content.tmp" "staging2_${b}.tmp"
            # Delete the line above inserted content
            sed -i '' "/\${Replace_Content}/d" "staging2_${b}.tmp"
        fi

        echo "   > Writing template to $b" >> build.log
        cat "staging2_${b}.tmp" > "$b"
        
        # Remove modified staging file for client/master
        rm "staging2_${b}.tmp"
        
    done #end base.html, base_master.html iteration
    
    # Remove staging files for iterations of base
    rm "staging_${base}.tmp" # Pre client/master split
    rm "staging_${base}_content.tmp" # formatted copy of parent file
    
    
done # end content/ directory iteration



# Set system variable back to what it was
IFS=$Field_Separator


echo "" >> build.log
echo "==================================================" >> build.log
# Append the previous log to the bottom of current log
cat "build_log.tmp" >> build.log
rm "build_log.tmp" # Remove temporary log
