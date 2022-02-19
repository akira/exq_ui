import { ViewHook } from "phoenix_live_view";

function relativeTime(dateString) {
  if (
    typeof window.Intl != "object" ||
    typeof window.Intl.RelativeTimeFormat != "function"
  ) {
    return dateString;
  }

  let date = new Date(dateString);
  let value = (date - new Date()) / 1000;
  const abs = Math.abs(value);
  let unit;
  if (abs < 60) {
    unit = "second";
  } else if (abs < 60 * 60) {
    unit = "minute";
    value = value / 60;
  } else if (abs < 60 * 60 * 60) {
    unit = "hour";
    value = value / (60 * 60);
  } else {
    unit = "day";
    value = value / (60 * 60 * 60);
  }

  const rtf = new Intl.RelativeTimeFormat("en", { numeric: "auto" });
  return rtf.format(Math.round(value), unit);
}

/** @type {ViewHook}*/
let Timestamp = {
  mounted() {
    let dateString = this.el.textContent.trim();
    this.el.innerText = relativeTime(dateString);
  },
};

export { Timestamp };
