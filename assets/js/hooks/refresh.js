import { ViewHook } from "phoenix_live_view";

const refresh_interval_key = "refresh_interval";

/** @type {ViewHook}*/
let Refresh = {
  mounted() {
    const that = this;
    this.el.addEventListener("change", function (event) {
      const interval = Number(event.target.value);
      localStorage.setItem(refresh_interval_key, interval);
      that.pushEventTo("#stats", "refresh-interval", {
        interval: interval,
      });
    });

    const interval = Number(localStorage.getItem(refresh_interval_key)) || 5;
    this.el.value = interval;
    that.pushEventTo("#stats", "refresh-interval", {
      interval: interval,
    });
  },
};

export { Refresh };
