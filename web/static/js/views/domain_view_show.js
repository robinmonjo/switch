import MainView from "./main_view";
import socket from "../socket";
import $ from "jquery"

export default class DomainViewShow extends MainView {
  mount() {
    super.mount();

    const checkDomainBtn = $("#check-domain")
    if (!checkDomainBtn.length) {
      return
    }

    socket.connect()

    let channel = socket.channel("domains:" + "11111111111111111111")
    channel.join()
      .receive("ok", resp => {
        console.log("joined the domain channel", resp)
      })
      .receive("error", reason => {
        console.log("joined failed", reason)
      })

    channel.on("ping", ({count}) => {
      console.log("PING", count)
    })

    checkDomainBtn.click(() => {
      const domainId = checkDomainBtn.data("id")
      channel.push("check_domain", domainId)
        .receive("error", e => {
          console.log("error", e)
        })
    });

    channel.on("check_domain", resp => {
      console.log(resp)
    })
  }



  unmount() {
    super.unmount();
  }
}
