var streamId = document.getElementById("Task_output-content").getAttribute("data-stream-id");

var es = new EventSource("/stream/" + streamId);

var appendOutput = function(output) {
  document.getElementById("Task_output-content").insertAdjacentHTML("beforeend", output + "\n");
}

es.addEventListener("stdout", function(e) {
  var line = document.createElement("xmp");
  line.innerHTML = e.data;

  appendOutput(line.outerHTML);
});

es.addEventListener("stderr", function(e) {
  var line = document.createElement("xmp");
  line.innerHTML = e.data;

  var errorLine = document.createElement("span");
  errorLine.className = "Task_output-contentError";
  errorLine.innerHTML = line.outerHTML;

  appendOutput(errorLine.outerHTML);
});
