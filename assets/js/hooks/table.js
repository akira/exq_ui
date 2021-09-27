import { ViewHook } from "phoenix_live_view";

// Since it's not possible to identify which button triggered the form
// submission, normal button along with hidden input is used to
// simulate multiple submit button
// https://github.com/phoenixframework/phoenix_live_view/issues/511

/** @type {ViewHook}*/
let Table = {
  mounted() {
    let table = this.el;
    /** @type {HTMLInputElement} */
    let hiddenAction = table.querySelector(".js-hidden-submit");
    /** @type {HTMLInputElement} */
    let submitButton = table.querySelector(".js-submit-button");
    /** @type {HTMLInputElement} */
    let checkbox = table.querySelector(".js-select-all-rows");
    checkbox.addEventListener("change", function () {
      /** @type {NodeListOf<HTMLInputElement>} */
      let rowCheckBoxes = table.querySelectorAll(".js-select-row");
      rowCheckBoxes.forEach((elem) => {
        elem.checked = this.checked;
      });
    });

    /** @type {NodeListOf<HTMLButtonElement>} */
    let actions = table.querySelectorAll(".js-action");
    actions.forEach((action) => {
      action.addEventListener("click", function () {
        hiddenAction.value = this.dataset.name;
        submitButton.click();
      });
    });
  },
};

export { Table };
