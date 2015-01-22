$(document).ready(function () {
	var toggled = true;
$( "#clickme" ).click(function() {
  $( ".documentation" ).slideToggle( "slow", function() {
    // Animation complete.
  });
  if (toggled) {
  	$(this).text("Show Documentation")
  	toggled = false;
  } else {
  	$(this).text("Hide Documentation")
  	toggled = true;
  }


});
});
