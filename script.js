const welcome = document.getElementById("welcome");

const nextScreen = document.getElementById("nextScreen");

document.getElementById("enterButton").addEventListener("click", () => {

  welcome.classList.add("hidden");

  nextScreen.classList.remove("hidden");

  window.scrollTo({ top: 0, behavior: "smooth" });

});

document.getElementById("backButton").addEventListener("click", () => {

  nextScreen.classList.add("hidden");

  welcome.classList.remove("hidden");

  window.scrollTo({ top: 0, behavior: "smooth" });

});

// Subtle mouse movement effect on computers

const layers = document.querySelectorAll(".parallax");

if (window.matchMedia("(hover: hover) and (pointer: fine)").matches) {

  window.addEventListener("pointermove", (event) => {

    const x = (event.clientX / window.innerWidth - 0.5) * 2;

    const y = (event.clientY / window.innerHeight - 0.5) * 2;

    layers.forEach((layer) => {

      const depth = Number(layer.dataset.depth);

      layer.style.translate =

        `${x * depth * 4}px ${y * depth * 4}px`;

    });

  });

  document.addEventListener("pointerleave", () => {

    layers.forEach((layer) => {

      layer.style.translate = "";

    });

  });

}
 