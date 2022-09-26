function toggleDisplay() {
      var x = document.getElementById(arguments[0]);
      if (x.style.display === "none") {
        x.style.display = "block";
      } else {
        x.style.display = "none";
      }
}

function toggleVisible() {
  for (let i = 0; i < arguments.length; i++) {
      var x = document.getElementById(arguments[i]);
      x.classList.toggle('hidden'); // toggle the hidden class
  }
  toggleDisplay(arguments[1])
}
