// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import ClientMenuComponent from "ClientMenuComponent"
import "rails-ujs"

window.jQuery = $;
window.$ = $;

RailsUJS.start();
ActiveStorage.start();

document.addEventListener("turbo:load", () => {
    ClientMenuComponent();
});
