$(function(){
  $("#pg").show();

  $("#db_type").change(function(){
    hideDatabaseSelection();
    $("#" + $(this).val()).show();
    input_data();
  });

  function hideDatabaseSelection() {
    $("#pg").hide();
    $("#mysql").hide();
  }

  $("#pg").change(function(){
    input_data();
  });

  $("#mysql").change(function(){
    input_data();
  });

  function input_data() {
    $("#parameters").val(generate_data());
  }

  function generate_data() {
    return JSON.stringify({
      db_type: $("#db_type").val(),
      database: $("#pg").is(":visible") ? $("#pg").val() : $("#mysql").val(),
      action_name: $("#action_name").val()
    });
  }

  // $("#dbform").on("submit",function (event) {
    // event.preventDefault();
    // $.ajax({
    //   url: "/test",
    //   dataType: "json",
    //   contentType: "application/json",
    //   type: "POST",
    //   data : generate_data(),
    //   accepts: "application/json"
    // });
  // });

  input_data();
});
