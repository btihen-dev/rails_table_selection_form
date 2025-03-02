import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  // // naive version
  // filter(event) {
  //   clearTimeout(this.timeout);
  //   this.timeout = setTimeout(() => {
  //     this.element.requestSubmit();
  //   }, 300);
  // }
  //
  // // ********
  // // works with selection, but doesn't persist between filter or reloads
  // static targets = ["selectAll", "rowSelector"];
  // connect() {
  //   this.updateSelectedRows();
  // }
  // filter(event) {
  //   clearTimeout(this.timeout);
  //   this.timeout = setTimeout(() => {
  //     this.element.requestSubmit();
  //   }, 300);
  // }
  // selectRow(event) {
  //   this.updateSelectedRows();
  // }
  // toggleSelectAll() {
  //   const isChecked = this.selectAllTarget.checked;
  //   this.rowSelectorTargets.forEach((checkbox) => {
  //     checkbox.checked = isChecked;
  //   });
  //   this.updateSelectedRows();
  // }
  // updateSelectedRows() {
  //   const selectedRows = [];
  //   this.rowSelectorTargets.forEach((checkbox) => {
  //     if (checkbox.checked) {
  //       selectedRows.push(checkbox.value);
  //     }
  //   });
  //   const url = new URL(window.location);
  //   if (selectedRows.length > 0) {
  //     url.searchParams.set("selected_rows", selectedRows.join(","));
  //   } else {
  //     url.searchParams.delete("selected_rows");
  //   }
  //   // Update the URL without reloading the page
  //   window.history.replaceState({}, "", url);
  // }
  //
  // // ********
  // // should persist the selected rows in the url with reoload and filter changes (but drops non-visible rows)
  static targets = ["selectAll", "rowSelector"];
  connect() {
    // console.log("Controller connected");
    this.initializeSelectedRows();
  }
  // filter(event) {
  //   console.log("filter change");
  //   clearTimeout(this.timeout);
  //   this.timeout = setTimeout(() => {
  //     this.element.requestSubmit(); // can't use requestSubmit() since it will submit the selected_rows form too)
  //     this.initializeSelectedRows(); // Re-initialize selected rows after filtering
  //   }, 300);
  // }
  filter(event) {
    // console.log("filter change");
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
      const currentParams = new URLSearchParams(window.location.search);
      // Suppose the changed filter input has `name="last_name_filter"`
      // and its new value is in event.target.value
      currentParams.set(event.target.name, event.target.value);

      // Merge other existing params if needed (like selected_rows) -
      // this visit persists the selected rows - even those not visible
      Turbo.visit(`${window.location.pathname}?${currentParams.toString()}`, {
        action: "replace", // or 'advance'
      }).then(() => {
        this.initializeSelectedRows(); // // Re-initialize selected rows after filtering
      });
    }, 300);
  }
  selectRow(event) {
    // console.log("Row selected");
    if (!this.hasRowSelectorTarget) {
      console.error("No row selector targets found");
      return;
    }
    this.updateSelectedRows();
  }
  toggleSelectAll() {
    // console.log("toggleSelectAll");
    const isChecked = this.selectAllTarget.checked;
    this.rowSelectorTargets.forEach((checkbox) => {
      checkbox.checked = isChecked;
    });
    this.updateSelectedRows();
  }
  initializeSelectedRows() {
    // console.log("initializeSelectedRows");
    const urlParams = new URLSearchParams(window.location.search);
    const selectedRows = urlParams.get("selected_rows");
    // console.log("Initializing selected rows from URL:", selectedRows);
    if (selectedRows) {
      const selectedRowIds = selectedRows.split(",");
      this.rowSelectorTargets.forEach((checkbox) => {
        if (selectedRowIds.includes(checkbox.value)) {
          checkbox.checked = true;
        }
      });
    }
  }
  updateSelectedRows() {
    // console.log("Updating selected rows");
    const selectedRows = [];
    this.rowSelectorTargets.forEach((checkbox) => {
      if (checkbox.checked) {
        selectedRows.push(checkbox.value);
      }
    });
    const url = new URL(window.location);
    if (selectedRows.length > 0) {
      url.searchParams.set("selected_rows", selectedRows.join(","));
    } else {
      url.searchParams.delete("selected_rows");
    }
    console.log("Updating URL with selected rows:", selectedRows);
    // Update the URL without reloading the page
    window.history.replaceState({}, "", url);
  }
}
