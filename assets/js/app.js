// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html";

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

// setup inspired by: https://blog.diacode.com/page-specific-javascript-in-phoenix-framework-pt-1

import MainView from "./views/main_view";
import DomainViewShow from "./views/domain_view_show";

// Collection of specific view modules
const views = {
  "domain_view_show": DomainViewShow
};

function handleDOMContentLoaded() {
  const viewName = window.jsViewName; //this is set in the app layout
  const viewClass = views[viewName] || MainView;
  const view = new viewClass();
  view.mount();
  window.currentView = view;
}

function handleDocumentUnload() {
  window.currentView.unmount();
}

window.addEventListener("DOMContentLoaded", handleDOMContentLoaded, false);
window.addEventListener("unload", handleDocumentUnload, false);
