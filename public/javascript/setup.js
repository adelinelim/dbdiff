$(function(){
  $("#all_databases").change(function(){
    input_data();
  });

  function input_data() {
    $("#cid").val($("#all_databases").val());
  }

  input_data();
});
