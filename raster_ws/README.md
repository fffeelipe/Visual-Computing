# Taller raster

## Propósito

Comprender algunos aspectos fundamentales del paradigma de rasterización.

## Tareas

Emplee coordenadas baricéntricas para:

1. Rasterizar un triángulo; y,
2. Sombrear su superficie a partir de los colores de sus vértices.

Referencias:

* [The barycentric conspiracy](https://fgiesen.wordpress.com/2013/02/06/the-barycentric-conspirac/)
* [Rasterization stage](https://www.scratchapixel.com/lessons/3d-basic-rendering/rasterization-practical-implementation/rasterization-stage)

Opcionales:

1. Implementar un [algoritmo de anti-aliasing](https://www.scratchapixel.com/lessons/3d-basic-rendering/rasterization-practical-implementation/rasterization-practical-implementation) para sus aristas; y,
2. Sombrear su superficie mediante su [mapa de profundidad](https://en.wikipedia.org/wiki/Depth_map).

Implemente la función ```triangleRaster()``` del sketch adjunto para tal efecto, requiere la librería [frames](https://github.com/VisualComputing/frames/releases).

## Integrantes

Dos, o máximo tres si van a realizar al menos un opcional.

Complete la tabla:

| Integrante | github nick |
|------------|-------------|
| Luis Felipe Epia Realpe           |  fffeelipe |
| Santiago Orloff Orloff Rodríguez           |  Orloffyeah |

## Discusión

Describa los resultados obtenidos. En el caso de anti-aliasing describir las técnicas exploradas, citando las referencias.

Para rasterizar el triangulo, se usaron coordenadas baricentricas por su propiedad de mostrar el "peso" de cada vértice en cada punto del plano; con estos valores se hizo la interpretación de los valores para los colores.

También tiene la propiedad de que si el punto objetivo no está dentro del triangulo, alguno de los pesos será mayor a 1 o menor que 0, que fue lo que se usó para determinar si cada punto estaba dentro del triangulo.
En caso de estar dentro del triangulo, como la suma de las coordenadas baricentricas debe ser uno, se multiplicaba el valor de cada color con su respectiva coordenada y se sumaban, ello daba un promedio ponderado para el color.
Para saber si el triangulo no estaba dentro del triangulo se elegía como punto objetivo el centro del "pixel" objetivo (se usaban números punto flotante para los cálculos).

La implementación del anti-aliasing se basó en el método descrito en la página [Scratch a Pixel](https://www.scratchapixel.com/lessons/3d-basic-rendering/rasterization-practical-implementation/rasterization-practical-implementation), el cuál fué sugerido por el profesor.
En este artículo se explica como el proceso de anti-aliasing consiste en tomar una sección del borde de la figura y dividr cada pixel en varios sub-pixeles, a los cuales se les realiza una revisión del color. Posteriormente se toma el promedio de colores y se aplica al pixel original, resultando en un borde mas gradual y "suave",

## Entrega

* Modo de entrega: [Fork](https://help.github.com/articles/fork-a-repo/) la plantilla en las cuentas de los integrantes.
* Plazo: 30/9/18 a las 24h.