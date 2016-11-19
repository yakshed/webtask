var streamId = document.getElementById("Task_output-content").getAttribute("data-stream-id");

var es = new EventSource("/stream/" + streamId);

var appendOutput = function(output) {
  document.getElementById("Task_output-content").insertAdjacentHTML("beforeend", output + "\n");
}

es.addEventListener("stdout", function(e) {
  appendOutput(e.data);
});

es.addEventListener("stderr", function(e) {
  var errorLine = document.createElement("span");
  errorLine.className = "Task_output-contentError";
  errorLine.innerHTML = e.data;

  appendOutput(errorLine.outerHTML);
});
