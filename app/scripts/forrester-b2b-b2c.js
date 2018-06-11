$(".order-actions-toolbar .actions").append("<a id=\"edit-order\">Edit</a>");

$(document).on("click", "#edit-order", function(){
  $("ul.items-qty").replaceWith("<input id=\"items-qty\" class=\"items-qty\" type=\"number\" value=\"1\">");
  $("#my-orders-table").before("<a id=\"add-item\">Add Product</a>");
  $("strong.product.name.product-item-name").append("<a id=\"del-item\"></a>");
  $("#edit-order").replaceWith("<a id=\"save-order\">Save</a>");
  $("#maincontent > div.page.messages > div > div > div").remove();
});

$(document).on("click", "#add-item", function(){
  $("tr[id^='order-item-row']").after("<tr id=\"order-item-new-row\"><td class=\"col name\"><input id=\"items-sku\" class=\"items-sku\" type=\"text\" value=\"Search Name or SKU\"  onfocus=\"this.value=''\"><a id=\"del-item\"></a></td><td class=\"col sku\"> </td><td class=\"col price\"> </td><td class=\"col qty\"> </td><td class=\"col subtotal\"> </td></tr>");
});

$(document).on("click", "#del-item", function(){
  $(this).closest('tr').remove();
});

$(document).on("click", "#items-sku", function(){
  var validcode = "MIL230622";
  $("#items-sku").keyup(function () {
      var code = $(this).val();
      if (code === validcode) {
          $("tr#order-item-new-row").replaceWith("<tr id=\"order-item-new-row\"><td class=\"col name\"><strong class=\"product name product-item-name\">Milwaukee M12 Hammervac Universal Dust Extractor Kit<a id=\"del-item\"></a></strong></td><td class=\"col sku\">MIL230622</td><td class=\"col price\"><span class=\"price\">$305.45</span></td><td class=\"col qty\"><input id=\"items-qty\" class=\"items-qty\" type=\"number\" value=\"1\"></td><td class=\"col subtotal\"><span class=\"price\">$305.45</span></td></tr>");
          $("#my-orders-table > tfoot > tr.subtotal > td > span").replaceWith("$350.45");
          $("#my-orders-table > tfoot > tr.grand_total > td > strong > span").replaceWith("$375.45");
      } else {
        //
      }
  });
});

$(document).on("click", "#save-order", function(){
  $("#maincontent > div.page.messages").append("<div data-bind=\"scope: 'messages'\"><div role=\"alert\" data-bind=\" \" class=\"messages\"><div class=\"message-success success message\" data-ui-id=\"message-success\"><div data-bind=\"\">You saved the order.</div></div></div></div>")
  $("#save-order").replaceWith("<a id=\"edit-order\">Edit</a>");
  $("input[id^='items-qty']").replaceWith( "<span>1</span>" );
  $("#maincontent > div.columns > div.column.main > div.page-title-wrapper > span").replaceWith("<span class=\"order-status\">Edited (Pending)</span>");
  $("#add-item").remove();
  $("#del-item").remove();
});
