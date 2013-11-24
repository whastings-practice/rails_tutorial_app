(function(window, document) {

  window.onload = function() {
    var input = document.querySelector('.text-countable'),
        charCount = document.querySelector('.chars-remaining'),
        maxChars = 140;

    function updateCount(event) {
      charCount.innerHTML = (140 - input.value.length);
    }

    input.addEventListener('keyup', updateCount);
    updateCount();
  };

})(window, document);
