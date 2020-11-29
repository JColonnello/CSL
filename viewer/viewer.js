// Three.js - Shadertoy Basic x40
// from https://threejsfundamentals.org/threejs/threejs-shadertoy-basic-x40.html

import * as THREE from 'https://threejsfundamentals.org/threejs/resources/threejs/r122/build/three.module.js';

function main() {
	const canvas = document.querySelector('#c');
	const uploader = document.getElementById('inp');
	const renderer = new THREE.WebGLRenderer({
		canvas
	});
	renderer.autoClearColor = false;

	const camera = new THREE.OrthographicCamera(
		-1, // left
		1, // right
		1, // top
		-1, // bottom
		-1, // near,
		1, // far
	);
	const scene = new THREE.Scene();
	const plane = new THREE.PlaneBufferGeometry(2, 2);

	const shaderPrologue = `
	uniform vec4 iResolution;
	uniform float iTime;
	uniform vec4 iMouse;
  	`;
	const uniforms = {
		iTime: {
			value: 0
		},
		iResolution: {
			value: new THREE.Vector4()
		},
		iMouse: {
			value: new THREE.Vector4()
		}
	};
	
	const mesh = new THREE.Mesh(plane);

	function resizeRendererToDisplaySize(renderer) {
		const canvas = renderer.domElement;
		const width = canvas.clientWidth;
		const height = canvas.clientHeight;
		const needResize = canvas.width !== width || canvas.height !== height;
		if (needResize) {
			renderer.setSize(width, height, false);
		}
		return needResize;
	}

	function render(time) {
		time *= 0.001; // convert to seconds

		resizeRendererToDisplaySize(renderer);

		const canvas = renderer.domElement;
		uniforms.iResolution.value.set(canvas.width, canvas.height, 0, 0);
		uniforms.iTime.value = time;

		renderer.render(scene, camera);

		requestAnimationFrame(render);
	}

	function loadFileAsText() {
		var fileToLoad = uploader.files[0];
	  
		var fileReader = new FileReader();
		fileReader.onload = function(fileLoadedEvent){
			scene.remove(mesh);
			var textFromFileLoaded = fileLoadedEvent.target.result;
			const material = new THREE.ShaderMaterial({
				uniforms,
			});
			material.fragmentShader = shaderPrologue + textFromFileLoaded;
			mesh.material = material;
			scene.add(mesh);
		};
	  
		fileReader.readAsText(fileToLoad, "UTF-8");
	}

	function updateMouse(e) {
		uniforms.iMouse.value.set(e.offsetX, e.offsetY, 0, 0);
	}

	canvas.onmousedown = function() {
		canvas.addEventListener('mousemove', updateMouse);
	};
	canvas.onmouseup = function () {
		canvas.removeEventListener('mousemove', updateMouse);
	};
	canvas.onmouseout = function () {
		canvas.removeEventListener('mousemove', updateMouse);
	};
	document.getElementById("loadButton").onclick = loadFileAsText;

	requestAnimationFrame(render);
}

main();