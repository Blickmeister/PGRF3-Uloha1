package uloha1;


import javafx.scene.shape.Sphere;
import lvl2advanced.p01gui.p01simple.AbstractRenderer;
import lwjglutils.*;
import org.lwjgl.BufferUtils;
import org.lwjgl.glfw.*;
import transforms.*;

import java.io.IOException;
import java.nio.DoubleBuffer;
import java.nio.FloatBuffer;

import static org.lwjgl.glfw.GLFW.*;
import static org.lwjgl.opengl.GL11.*;
import static org.lwjgl.opengl.GL20.*;
import static org.lwjgl.opengl.GL30.*;


/**
 *
 * @author PGRF FIM UHK
 * @version 2.0
 * @since 2019-09-02
 */
public class Renderer extends AbstractRenderer{

	double ox, oy;
	boolean mouseButton1, mouseButton2 = false;

	OGLBuffers buffers;
	OGLTexture2D texture;
	OGLTexture.Viewer textureViewer;
	OGLRenderTarget renderTarget;

	int shaderProgramLight, shaderProgramView, shaderProgramPhong;

	int width, height;

	// uniform lokátory
	int  locTime, locMathModelView, locMathViewView, locMathProjView;
	int  locMathModelLight, locMathViewLight, locMathProjLight, locLightPos,
			locMathMVPLight, locObjectType, locLightModelType, locObjectTypeForLight;

	// proměnné pro přepínání módů
	int switchLightModel = 0;

	// proměnné pro shadery
	float time, rot1, rot2 = 0;
	Mat4 matMVPLight = new Mat4Identity();
	Vec3D light = new Vec3D();


	// vytvoření kamery a definice projekce
	Camera cam = new Camera();
	Mat4 proj = new Mat4PerspRH(Math.PI / 4, 1, 0.01, 100.0);

	// ovládání tlačítky
	private GLFWKeyCallback   keyCallback = new GLFWKeyCallback() {
		@Override
		public void invoke(long window, int key, int scancode, int action, int mods) {
			if ( key == GLFW_KEY_ESCAPE && action == GLFW_RELEASE )
				glfwSetWindowShouldClose(window, true); // We will detect this in the rendering loop
			if (action == GLFW_PRESS || action == GLFW_REPEAT){
				switch (key) {
					case GLFW_KEY_W:
						cam = cam.forward(1);
						break;
					case GLFW_KEY_D:
						cam = cam.right(1);
						break;
					case GLFW_KEY_S:
						cam = cam.backward(1);
						break;
					case GLFW_KEY_A:
						cam = cam.left(1);
						break;
					case GLFW_KEY_LEFT_CONTROL:
						cam = cam.down(1);
						break;
					case GLFW_KEY_LEFT_SHIFT:
						cam = cam.up(1);
						break;
					case GLFW_KEY_SPACE:
						cam = cam.withFirstPerson(!cam.getFirstPerson());
						break;
					case GLFW_KEY_R:
						cam = cam.mulRadius(0.9f);
						break;
					case GLFW_KEY_F:
						if(switchLightModel == 1) {
							switchLightModel = 0;
						} else {
							switchLightModel++;
						}
						break;
				}
			}
		}
	};

	// resize okna
	private GLFWWindowSizeCallback wsCallback = new GLFWWindowSizeCallback() {
		@Override
		public void invoke(long window, int w, int h) {
			if (w > 0 && h > 0 &&
					(w != width || h != height)) {
				width = w;
				height = h;
				proj = new Mat4PerspRH(Math.PI / 4, height / (double) width, 0.01, 100.0);
				if (textRenderer != null)
					textRenderer.resize(width, height);
			}
		}
	};

	// ovládání myší
	private GLFWMouseButtonCallback mbCallback = new GLFWMouseButtonCallback () {
		@Override
		public void invoke(long window, int button, int action, int mods) {
			mouseButton1 = glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_1) == GLFW_PRESS;
			mouseButton2 = glfwGetMouseButton(window, GLFW_MOUSE_BUTTON_2) == GLFW_PRESS;

			if (button==GLFW_MOUSE_BUTTON_1 && action == GLFW_PRESS){
				mouseButton1 = true;
				DoubleBuffer xBuffer = BufferUtils.createDoubleBuffer(1);
				DoubleBuffer yBuffer = BufferUtils.createDoubleBuffer(1);
				glfwGetCursorPos(window, xBuffer, yBuffer);
				ox = xBuffer.get(0);
				oy = yBuffer.get(0);
			}

			if (button==GLFW_MOUSE_BUTTON_1 && action == GLFW_RELEASE){
				mouseButton1 = false;
				DoubleBuffer xBuffer = BufferUtils.createDoubleBuffer(1);
				DoubleBuffer yBuffer = BufferUtils.createDoubleBuffer(1);
				glfwGetCursorPos(window, xBuffer, yBuffer);
				double x = xBuffer.get(0);
				double y = yBuffer.get(0);
				cam = cam.addAzimuth((double) Math.PI * (ox - x) / width)
						.addZenith((double) Math.PI * (oy - y) / width);
				ox = x;
				oy = y;
			}
		}
	};

	private GLFWCursorPosCallback cpCallbacknew = new GLFWCursorPosCallback() {
		@Override
		public void invoke(long window, double x, double y) {
			if (mouseButton1) {
				cam = cam.addAzimuth((double) Math.PI * (ox - x) / width)
						.addZenith((double) Math.PI * (oy - y) / width);
				ox = x;
				oy = y;
			}
		}
	};

	private GLFWScrollCallback scrollCallback = new GLFWScrollCallback() {
		@Override
		public void invoke(long window, double dx, double dy) {
			if (dy < 0)
				cam = cam.mulRadius(0.9f);
			else
				cam = cam.mulRadius(1.1f);

		}
	};

	@Override
	public GLFWKeyCallback getKeyCallback() {
		return keyCallback;
	}

	@Override
	public GLFWWindowSizeCallback getWsCallback() {
		return wsCallback;
	}

	@Override
	public GLFWMouseButtonCallback getMouseCallback() {
		return mbCallback;
	}

	@Override
	public GLFWCursorPosCallback getCursorCallback() {
		return cpCallbacknew;
	}

	@Override
	public GLFWScrollCallback getScrollCallback() {
		return scrollCallback;
	}


	// vytvoření gridu - VB a IB
	void createBuffers(int m) {

		BufferGenerator buf = new BufferGenerator();

		buf.createVertexBuffer(m,m);
		//buf.createIndexBuffer(m , m);
		buf.createIndexBufferTriangleStrips(m,m);

		float[] vertexBufferData = buf.getVertexBufferData();
		int[] indexBufferData = buf.getIndexBufferData();

		for(int i = 0; i < indexBufferData.length; i++){
			System.out.print(indexBufferData[i] + "  ");
		}

		// nabindování a vlastnosti VB
		OGLBuffers.Attrib[] attributes = {
				new OGLBuffers.Attrib("inPosition", 2), // 2 floats
				//new OGLBuffers.Attrib("inColor", 3) // 3 floats
		};
		buffers = new OGLBuffers(vertexBufferData, attributes,
				indexBufferData);
	}

	// inicializace scény
	@Override
	public void init() {
		OGLUtils.printOGLparameters();
		OGLUtils.printLWJLparameters();
		OGLUtils.printJAVAparameters();

		// Set the clear color
		glClearColor(0.8f, 0.8f, 0.8f, 1.0f);

		createBuffers(50);

		// init shaderů
		shaderProgramLight = ShaderUtils.loadProgram("/uloha1/light");

		shaderProgramView = ShaderUtils.loadProgram("/uloha1/view");

		//shaderProgramPhong = ShaderUtils.loadProgram("/uloha1/phong");

		// nastavení aktuálního shaderu
		glUseProgram(this.shaderProgramLight);

		// načtení textury
		try {
			texture = new OGLTexture2D("textures/globeNormal.png");
		} catch (IOException e) {
			e.printStackTrace();
		}

		// init lokátorů
		locMathModelLight = glGetUniformLocation(shaderProgramLight, "model");
		locMathViewLight = glGetUniformLocation(shaderProgramLight, "view");
		locMathProjLight = glGetUniformLocation(shaderProgramLight, "proj");
		locObjectTypeForLight = glGetUniformLocation(shaderProgramLight, "objectType");

		locMathModelView = glGetUniformLocation(shaderProgramView, "model");
		locMathViewView = glGetUniformLocation(shaderProgramView, "view");
		locMathProjView = glGetUniformLocation(shaderProgramView, "proj");
		locLightPos = glGetUniformLocation(shaderProgramView, "lightPos");
		locMathMVPLight = glGetUniformLocation(shaderProgramView,"matMVPLight");
		locLightModelType = glGetUniformLocation(shaderProgramView, "lightModelType");
		locObjectType = glGetUniformLocation(shaderProgramView, "objectType");
		locTime = glGetUniformLocation(shaderProgramView, "time");

		textRenderer = new OGLTextRenderer(width, height);

		// definice kamery
		cam = cam.withPosition(new Vec3D(5, 5, 2.5))
				.withAzimuth(Math.PI * 1.25)
				.withZenith(Math.PI * -0.125);

		textureViewer = new OGLTexture2D.Viewer();
		renderTarget = new OGLRenderTarget(1024, 1024);
	}

	// metoda pro renderování z pohledu kamery do obrazovky
	public void renderFromView() {
		glBindFramebuffer(GL_FRAMEBUFFER, 0);
		glViewport(0, 0, width, height);
		glClearColor(0.5f, 0.1f, 0.1f, 1f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); // clear the framebuffer

		glUseProgram(shaderProgramView);

		glUniform1i(locLightModelType, switchLightModel);
		glUniform1f(locTime, time);
		glUniform3fv(locLightPos, new float[]{(float)light.getX(), (float)light.getY(), (float)light.getZ()});

		glUniformMatrix4fv (locMathMVPLight, false,
				matMVPLight.floatArray());
		glUniformMatrix4fv (locMathViewView, false,
				cam.getViewMatrix().floatArray());
		glUniformMatrix4fv (locMathProjView, false,
				proj.floatArray());

		texture.bind(shaderProgramView,"textureID",0);
		renderTarget.getDepthTexture().bind(shaderProgramView,"textureDepth",1);

		// bind and draw
		//int locMode = glGetUniformLocation(shaderProgramView,"mode");

		glUniform1i(locObjectType, 0); //plane
		glUniformMatrix4fv (locMathModelView, false,
				new Mat4Scale(15).floatArray());
		buffers.draw(GL_TRIANGLE_STRIP, shaderProgramView);


		glUniform1i(locObjectType, 1); //object
		glUniformMatrix4fv (locMathModelView, false,
				new Mat4RotX(rot1).mul(new Mat4Transl(0,0,2)).floatArray());
		buffers.draw(GL_TRIANGLE_STRIP, shaderProgramView);


		/*glUniform1i(locMode, 2); //vlnka
		if(switchShaderProgram == 0) {
			buffers.draw(GL_TRIANGLES, shaderProgramView);
		} else if(switchShaderProgram == 1) {
			buffers.draw(GL_TRIANGLES, shaderProgramPhong);
		}*/
		glUniform1i(locObjectType, 2); //light position
		glUniformMatrix4fv (locMathModelView, false,
				new Mat4Transl(light).mul(new Mat4Scale(0.5)).floatArray());
		buffers.draw(GL_TRIANGLE_STRIP, shaderProgramView);

		glUniform1i(locObjectType, 3); // cone
		glUniformMatrix4fv (locMathModelView, false,
				new Mat4RotX(rot1).mul(new Mat4Transl(3,0,3)).floatArray());
		buffers.draw(GL_TRIANGLE_STRIP, shaderProgramView);

		glUniform1i(locObjectType, 4); // elephant head
		glUniformMatrix4fv (locMathModelView, false,
				new Mat4RotX(rot1).mul(new Mat4Transl(12,0,5)).mul(new Mat4Scale(0.20)).floatArray());
		buffers.draw(GL_TRIANGLE_STRIP, shaderProgramView);

		glUniform1i(locObjectType, 5); // my battle station
		glUniformMatrix4fv (locMathModelView, false,
				new Mat4RotX(rot1).mul(new Mat4Transl(5,15,4)).mul(new Mat4Scale(0.20)).floatArray());
		buffers.draw(GL_TRIANGLE_STRIP, shaderProgramView);

		glUniform1i(locObjectType, 6); // sombrero
		glUniformMatrix4fv (locMathModelView, false,
				new Mat4RotX(rot1).mul(new Mat4Transl(25,-15,12)).mul(new Mat4Scale(0.15)).floatArray());
		buffers.draw(GL_TRIANGLE_STRIP, shaderProgramView);

		glUniform1i(locObjectType, 7); // spiral
		glUniformMatrix4fv (locMathModelView, false,
				new Mat4RotX(rot1).mul(new Mat4Transl(-5,-3,6)).mul(new Mat4Scale(0.15)).floatArray());
		buffers.draw(GL_TRIANGLE_STRIP, shaderProgramView);



		textureViewer.view(renderTarget.getColorTexture(),-1,-1,0.5);
		textureViewer.view(renderTarget.getDepthTexture(),-1,0,0.5);

		String text = new String(this.getClass().getName() + ": [LMB] camera, WSAD");
		textRenderer.clear();
		textRenderer.addStr2D(3, 20, text);
		textRenderer.addStr2D(width-90, height-3, " (c) PGRF UHK");
		textRenderer.draw();
	}

	// metoda pro renderování z pohledu světla do render targetu
	public void renderFromLight() {
		renderTarget.bind();
		glClearColor(0.1f, 0.5f, 0.1f, 1f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); // clear the framebuffer

		glUseProgram(shaderProgramLight);
		light = new Vec3D(0, 0, 18).mul(new Mat3RotX(rot2 *2));

		glUniformMatrix4fv (locMathModelLight, false,
				new Mat4RotX(rot1).mul(new Mat4Transl(0,0,1)).floatArray());
		glUniformMatrix4fv (locMathViewLight, false,
				new Mat4ViewRH(light, light.mul(-1), new Vec3D(0,1,0)).floatArray());
		glUniformMatrix4fv (locMathProjLight, false,
				new Mat4OrthoRH(10,10,1,20).floatArray());


		matMVPLight =  new Mat4ViewRH(light, light.mul(-1), new Vec3D(0,1,0))
				.mul(new Mat4OrthoRH(10,10,1,20));

		// bind and draw
		//buffers.draw(GL_TRIANGLES, shaderProgramLight);

		glUniform1i(locObjectTypeForLight, 0); //plane
		glUniformMatrix4fv (locMathModelLight, false,
				new Mat4Scale(15).floatArray());
		buffers.draw(GL_TRIANGLE_STRIP, shaderProgramLight);

		glUniform1i(locObjectTypeForLight, 1); //object
		glUniformMatrix4fv (locMathModelLight, false,
				new Mat4RotX(rot1).mul(new Mat4Transl(0,0,2)).floatArray());
		buffers.draw(GL_TRIANGLE_STRIP, shaderProgramLight);

		glUniform1i(locObjectTypeForLight, 2); // cone
		glUniformMatrix4fv (locMathModelLight, false,
				new Mat4RotX(rot1).mul(new Mat4Transl(3,0,3)).floatArray());
		buffers.draw(GL_TRIANGLE_STRIP, shaderProgramLight);

		glUniform1i(locObjectTypeForLight, 3); // elephant head
		glUniformMatrix4fv (locMathModelLight, false,
				new Mat4RotX(rot1).mul(new Mat4Transl(12,0,5)).mul(new Mat4Scale(0.20)).floatArray());
		buffers.draw(GL_TRIANGLE_STRIP, shaderProgramLight);

		glUniform1i(locObjectTypeForLight, 4); // my battle station
		glUniformMatrix4fv (locMathModelLight, false,
				new Mat4RotX(rot1).mul(new Mat4Transl(5,15,4)).mul(new Mat4Scale(0.20)).floatArray());
		buffers.draw(GL_TRIANGLE_STRIP, shaderProgramLight);

		glUniform1i(locObjectTypeForLight, 5); // sombrero
		glUniformMatrix4fv (locMathModelLight, false,
				new Mat4RotX(rot1).mul(new Mat4Transl(25,-15,12)).mul(new Mat4Scale(0.15)).floatArray());
		buffers.draw(GL_TRIANGLE_STRIP, shaderProgramLight);

		glUniform1i(locObjectTypeForLight, 6); // spiral
		glUniformMatrix4fv (locMathModelLight, false,
				new Mat4RotX(rot1).mul(new Mat4Transl(-5,-3,6)).mul(new Mat4Scale(0.15)).floatArray());
		buffers.draw(GL_TRIANGLE_STRIP, shaderProgramLight);
	}

	// vykreslení scény
	@Override
	public void display() {
		glEnable(GL_DEPTH_TEST); // zapnutí z-testu
		glPolygonMode(GL_FRONT_AND_BACK, GL_FILL); // přepínání mezi drátovým modelem a vyplněnými plochami TODO
		glLineWidth(5); // šířka čar
		time += 0.01;
		// zastavení pohybu světla a modelu
		if (!mouseButton1)
			rot1 += 0.01;
		if (!mouseButton2)
			rot2 += 0.01;

		//renderování z pohledu světla do render targetu
		renderFromLight();
		//glFrontFace(GL_CW);
		//renderování z pohledu kamery do obrazovky
		renderFromView();
	}
}
