// Cituro online booking widget wiring.
// The loader script (index.html) exposes a global `cituroWidget` and renders
// its own button into any element with class="cituroContainer".
document.querySelectorAll('.js-book-btn').forEach(function (btn) {
  btn.addEventListener('click', function (event) {
    if (window.cituroWidget && typeof window.cituroWidget.show === 'function') {
      event.preventDefault();
      window.cituroWidget.show();
    }
  });
});
