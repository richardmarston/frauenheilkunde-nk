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

// Deep link for the ordination-sign QR code (see /qr): landing on #book
// auto-opens the booking dialog. The widget script loads async, so poll
// briefly for it instead of assuming it's ready on DOMContentLoaded.
if (window.location.hash === '#book') {
  (function waitForCituroWidget(attemptsLeft) {
    if (window.cituroWidget && typeof window.cituroWidget.show === 'function') {
      window.cituroWidget.show();
      return;
    }
    if (attemptsLeft <= 0) return;
    setTimeout(function () { waitForCituroWidget(attemptsLeft - 1); }, 200);
  })(25);
}
