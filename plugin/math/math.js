<<<<<<< HEAD
!function(e,t){"object"==typeof exports&&"undefined"!=typeof module?module.exports=t():"function"==typeof define&&define.amd?define(t):(e=e||self).RevealMath=t()}(this,(function(){"use strict";function e(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function t(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function n(n){for(var r=1;r<arguments.length;r++){var a=null!=arguments[r]?arguments[r]:{};r%2?t(Object(a),!0).forEach((function(t){e(n,t,a[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(n,Object.getOwnPropertyDescriptors(a)):t(Object(a)).forEach((function(e){Object.defineProperty(n,e,Object.getOwnPropertyDescriptor(a,e))}))}return n}return function(){var e,t={messageStyle:"none",tex2jax:{inlineMath:[["$","$"],["\\(","\\)"]],skipTags:["script","noscript","style","textarea","pre"]},skipStartupTypeset:!0};return{id:"math",init:function(r){var a=(e=r).getConfig().math||{},o=n(n({},t),a),c=(o.mathjax||"https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js")+"?config="+(o.config||"TeX-AMS_HTML-full");o.tex2jax=n(n({},t.tex2jax),a.tex2jax),o.mathjax=o.config=null,function(e,t){var n=this,r=document.querySelector("head"),a=document.createElement("script");a.type="text/javascript",a.src=e;var o=function(){"function"==typeof t&&(t.call(),t=null)};a.onload=o,a.onreadystatechange=function(){"loaded"===n.readyState&&o()},r.appendChild(a)}(c,(function(){MathJax.Hub.Config(o),MathJax.Hub.Queue(["Typeset",MathJax.Hub,e.getRevealElement()]),MathJax.Hub.Queue(e.layout),e.on("slidechanged",(function(e){MathJax.Hub.Queue(["Typeset",MathJax.Hub,e.currentSlide])}))}))}}}}));
=======
/**
 * A plugin which enables rendering of math equations inside
 * of reveal.js slides. Essentially a thin wrapper for MathJax.
 *
 * @author Hakim El Hattab
 */
var RevealMath = window.RevealMath || (function(){

	var options = Reveal.getConfig().math || {};
	var mathjax = options.mathjax || 'https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.0/MathJax.js';
	var config = options.config || 'TeX-AMS_HTML-full';
	var url = mathjax + '?config=' + config;

	var defaultOptions = {
		messageStyle: 'none',
		tex2jax: {
			inlineMath: [ [ '$', '$' ], [ '\\(', '\\)' ] ],
			skipTags: [ 'script', 'noscript', 'style', 'textarea', 'pre' ]
		},
		skipStartupTypeset: true
	};

	function defaults( options, defaultOptions ) {

		for ( var i in defaultOptions ) {
			if ( !options.hasOwnProperty( i ) ) {
				options[i] = defaultOptions[i];
			}
		}

	}

	function loadScript( url, callback ) {

		var head = document.querySelector( 'head' );
		var script = document.createElement( 'script' );
		script.type = 'text/javascript';
		script.src = url;

		// Wrapper for callback to make sure it only fires once
		var finish = function() {
			if( typeof callback === 'function' ) {
				callback.call();
				callback = null;
			}
		}

		script.onload = finish;

		// IE
		script.onreadystatechange = function() {
			if ( this.readyState === 'loaded' ) {
				finish();
			}
		}

		// Normal browsers
		head.appendChild( script );

	}

	return {
		init: function() {

			defaults( options, defaultOptions );
			defaults( options.tex2jax, defaultOptions.tex2jax );
			options.mathjax = options.config = null;

			loadScript( url, function() {

				MathJax.Hub.Config( options );

				// Typeset followed by an immediate reveal.js layout since
				// the typesetting process could affect slide height
				MathJax.Hub.Queue( [ 'Typeset', MathJax.Hub ] );
				MathJax.Hub.Queue( Reveal.layout );

				// Reprocess equations in slides when they turn visible
				Reveal.addEventListener( 'slidechanged', function( event ) {

					MathJax.Hub.Queue( [ 'Typeset', MathJax.Hub, event.currentSlide ] );

				} );

			} );

		}
	}

})();

Reveal.registerPlugin( 'math', RevealMath );
>>>>>>> f3764122e0d243f9feba380192b885a44804c58b
