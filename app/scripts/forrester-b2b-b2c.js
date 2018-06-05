$( ".order-actions-toolbar .actions" ).append( "<a id=\"edit-order\">Edit</a>" );

$(document).on("click", "#edit-order", function(){
  $("ul.items-qty").css( "border", "3px double red" );
});
