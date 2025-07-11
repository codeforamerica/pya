// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import ClientMenuComponent from "ClientMenuComponent"
import * as $ from "jquery"
import * as ActiveStorage from "@rails/activestorage"

window.jQuery = $;
window.$ = $;

ActiveStorage.start();

document.addEventListener("turbo:load", () => {
    ClientMenuComponent();
});
