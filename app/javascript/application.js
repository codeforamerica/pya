// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

window.jQuery = $;
window.$ = $;

RailsUJS.start();
ActiveStorage.start();

import "../lib/honeycrisp";
"./app/javascript/lib/honeycrisp.js":
