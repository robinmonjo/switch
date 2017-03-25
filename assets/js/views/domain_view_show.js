import MainView from "./main_view";
import socket from "../socket";
import $ from "jquery"

export default class DomainViewShow extends MainView {
  mount() {
    super.mount();

    const checkDomainBtn = $("#check-domain");
    if (!checkDomainBtn.length) {
      return;
    }

    socket.connect();

    const domainId = checkDomainBtn.data("id");

    let channel = socket.channel(`domains:${domainId}`)
    channel.join()
      .receive("ok", resp => {
        console.log("joined the domain channel", resp)
      })
      .receive("error", reason => {
        console.log("joined failed", reason)
      });

    channel.on("check_domain", resp => {
      console.log(resp)
    });

    checkDomainBtn.click(() => {
      channel.push("check_domain", domainId)
        .receive("error", e => {
          console.log("error", e)
        })
    });


  }



  unmount() {
    super.unmount();
  }
}
