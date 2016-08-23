$(function(){
  $("#adapter_select").change(function(){
    input_data();
  });

  function input_data() {
    $("#adapter").val($("#adapter_select").val());
  }

  input_data();
});
