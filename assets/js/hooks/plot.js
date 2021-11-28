import { ViewHook } from "phoenix_live_view";
import { axisLeft, axisBottom } from "d3-axis";
import { scaleLinear, scaleTime, scaleUtc } from "d3-scale";
import { extent, max, min } from "d3-array";
import { curveStep, line } from "d3-shape";
import { select } from "d3-selection";
import { transition } from "d3-transition";
import { easeLinear } from "d3-ease";
import { format } from "d3-format";

function graph(element) {
  const margin = { top: 10, right: 20, bottom: 30, left: 40 };
  const height = 250;
  const width = element.clientWidth;

  const svg = select(element)
    .append("svg")
    .attr("viewBox", [0, 0, width, height]);

  const xAxisGroup = svg
    .append("g")
    .attr("transform", `translate(0,${height - margin.bottom})`);

  const yAxisGroup = svg
    .append("g")
    .attr("transform", `translate(${margin.left}, 0)`);

  const processedPath = svg
    .append("path")
    .attr("fill", "none")
    .attr("stroke", "#007200")
    .attr("stroke-width", 1.5)
    .attr("stroke-linejoin", "round")
    .attr("stroke-linecap", "round");

  const failedPath = svg
    .append("path")
    .attr("fill", "none")
    .attr("stroke", "#dc3545")
    .attr("stroke-width", 1.5)
    .attr("stroke-linejoin", "round")
    .attr("stroke-linecap", "round");

  return (
    /** @type {Array<{
                  date: Date;
                  processed: number;
                  failed: number;
                  defined: boolean;
              }>} data
    **/
    data
  ) => {
    const x = scaleTime()
      .domain(extent(data, (d) => d.date))
      .range([margin.left, width - margin.right]);
    const xAxis = axisBottom(x);

    const y = scaleLinear()
      .domain([0, max(data, (d) => max([d.processed, d.failed]))])
      .range([height - margin.bottom, margin.top])
      .nice();

    const yAxis = axisLeft(y).ticks(7);

    const failed = line()
      .x((d) => x(d.date))
      .defined((d) => d.defined)
      .y((d) => y(d.failed));
    const processed = line()
      .x((d) => x(d.date))
      .defined((d) => d.defined)
      .y((d) => y(d.processed));

    xAxisGroup.call(xAxis);
    yAxisGroup.call(yAxis);

    processedPath.datum(data).attr("d", processed);
    failedPath.datum(data).attr("d", failed);
  };
}

/** @type {ViewHook}*/
let RealtimePlot = {
  mounted() {
    const data = [];
    const tick = Number(this.el.dataset.tick);

    let timestamp = new Date();
    for (let i = 0; i < 150; i++) {
      data.unshift({
        date: timestamp,
        processed: 0,
        failed: 0,
        defined: false,
      });
      timestamp = new Date(timestamp - tick);
    }

    const render = graph(this.el);
    render(data);

    this.handleEvent("append-point", ({ processed, failed }) => {
      data.shift();
      data.push({
        date: new Date(),
        processed: processed,
        failed: failed,
        defined: true,
      });
      render(data);
    });
  },
};

/** @type {ViewHook}*/
let HistoricalPlot = {
  mounted() {
    let data = [];
    const render = graph(this.el);
    render(data);

    this.handleEvent("replace-points", ({ points }) => {
      data = points.map((datum) => {
        datum.date = new Date(datum.date);
        datum.defined = true;
        return datum;
      });
      render(data);
    });
  },
};

export { RealtimePlot, HistoricalPlot };
