import "./style.css";
import Renderer from "./mnca";
import { Pane } from "tweakpane";
import * as EssentialsPlugin from "@tweakpane/plugin-essentials";

let size: number = parseInt(window.location.hash.substr(1));
size = size > 9 ? size : 512;
console.log(size);

const canvas = document.getElementById("gfx") as HTMLCanvasElement;
canvas.width = canvas.height = size;
const renderer = new Renderer(canvas);
renderer.start();

const pane = new Pane();
pane.registerPlugin(EssentialsPlugin);

const PARAMS = {
    Target: {r: 255, g: 0, b: 0},
  };
  
  pane.addInput(PARAMS, 'Target').on('change', (ev) => { if(ev.last) { renderer.render(ev.value) } });

//const f1 = pane.addFolder({ title: "Resolution" });
//f1.addInput(renderer, "resolution", { min: 10, max: 2048, step: 1 });
// f1.addButton({
//     title: "Apply (reload)",
// }).on("click", (value) => {
//     window.location.hash = "#" + renderer.resolution;
//     window.location.reload();
// });
// const f2 = pane.addFolder({ title: "Simulation" });
// f2.addInput(renderer, "nstates", { min: 0, max: 50, step: 1 }).on(
//     "change",
//     () => {
//         renderer.paramsNeedUpdate = true;
//     }
// );
// f2.addInput(renderer, "seedRadius", { min: 1, max: 20, step: 0.1 }).on(
//     "change",
//     () => {
//         renderer.paramsNeedUpdate = true;
//     }
// );
// const pauseBtn = f2
//     .addButton({
//         title: "Pause",
//     })
//     .on("click", (value) => {
//         renderer.isPaused = !renderer.isPaused;
//         pauseBtn.title = renderer.isPaused ? "Play" : "Pause";
//     });

// function resize() {
//     if (
//         document.documentElement.clientWidth >
//         document.documentElement.clientHeight
//     ) {
//         canvas.style.width = "auto";
//         canvas.style.height = "90%";
//     } else {
//         canvas.style.width = "90%";
//         canvas.style.height = "auto";
//     }
// }
// window.addEventListener("resize", resize);
//resize();
