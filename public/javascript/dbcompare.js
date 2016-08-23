$(function(){
  function getData() {
    return {
      "parameters": $("#parameters").val()
    };
  }

  // $("#compare").on("click",function() {
  //   $.ajax({
  //     url: "/compare",
  //     dataType: "json",
  //     contentType: "application/json",
  //     type: "GET",
  //     data: getData(),
  //     accepts: "application/json"
  //   });
  // });
});
