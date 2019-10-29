package Uloha1Pomocne;

import org.lwjgl.*;
import org.lwjgl.glfw.*;
import org.lwjgl.opengl.*;
import org.lwjgl.system.*;

import lwjglutils.ShaderUtils;
import lwjglutils.OGLBuffers;
import lwjglutils.OGLUtils;
import transforms.*;
import uloha1.BufferGenerator;

import java.nio.IntBuffer;

import static org.lwjgl.glfw.Callbacks.*;
import static org.lwjgl.glfw.GLFW.*;
import static org.lwjgl.opengl.GL11.glViewport;
import static org.lwjgl.opengl.GL33.*;
import static org.lwjgl.system.MemoryStack.*;
import static org.lwjgl.system.MemoryUtil.*;

public class App {

    int width, height;

    // The window handle
    private long window;

    OGLBuffers buffers;

    int shaderProgram, locMath;

    float time = 0;
    Mat4 mvp = new Mat4Identity();

    private void init() {
        // Setup an error callback. The default implementation
        // will print the error message in System.err.
        GLFWErrorCallback.createPrint(System.err).set();

        // Initialize GLFW. Most GLFW functions will not work before doing this.
        if ( !glfwInit() )
            throw new IllegalStateException("Unable to initialize GLFW");

        // Configure GLFW
        glfwDefaultWindowHints(); // optional, the current window hints are already the default
        glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE); // the window will stay hidden after creation
        glfwWindowHint(GLFW_RESIZABLE, GLFW_TRUE); // the window will be resizable

        // Create the window
        window = glfwCreateWindow(300, 300, "Hello World!", NULL, NULL);
        if ( window == NULL )
            throw new RuntimeException("Failed to create the GLFW window");

        // Setup a key callback. It will be called every time a key is pressed, repeated or released.
        glfwSetKeyCallback(window, (window, key, scancode, action, mods) -> {
            if ( key == GLFW_KEY_ESCAPE && action == GLFW_RELEASE )
                glfwSetWindowShouldClose(window, true); // We will detect this in the rendering loop
        });

        glfwSetFramebufferSizeCallback(window, new GLFWFramebufferSizeCallback() {
            @Override
            public void invoke(long window, int width, int height) {
                if (width > 0 && height > 0 &&
                        (App.this.width != width || App.this.height != height)) {
                    App.this.width = width;
                    App.this.height = height;
                }
            }
        });

        // Get the thread stack and push a new frame
        try ( MemoryStack stack = stackPush() ) {
            IntBuffer pWidth = stack.mallocInt(1); // int*
            IntBuffer pHeight = stack.mallocInt(1); // int*

            // Get the window size passed to glfwCreateWindow
            glfwGetWindowSize(window, pWidth, pHeight);

            // Get the resolution of the primary monitor
            GLFWVidMode vidmode = glfwGetVideoMode(glfwGetPrimaryMonitor());

            // Center the window
            glfwSetWindowPos(
                    window,
                    (vidmode.width() - pWidth.get(0)) / 2,
                    (vidmode.height() - pHeight.get(0)) / 2
            );
        } // the stack frame is popped automatically

        // Make the OpenGL context current
        glfwMakeContextCurrent(window);
        // Enable v-sync
        glfwSwapInterval(1);

        // Make the window visible
        glfwShowWindow(window);

        // This line is critical for LWJGL's interoperation with GLFW's
        // OpenGL context, or any context that is managed externally.
        // LWJGL detects the context that is current in the current thread,
        // creates the GLCapabilities instance and makes the OpenGL
        // bindings available for use.
        GL.createCapabilities();

        OGLUtils.printOGLparameters();
        OGLUtils.printLWJLparameters();
        OGLUtils.printJAVAparameters();

        // Set the clear color
        glClearColor(0.8f, 0.8f, 0.8f, 1.0f);

        createBuffers();

        shaderProgram = ShaderUtils.loadProgram("/uloha1/light.vert",
                "/lvl1basic/p01start/start.frag",
                null,null,null,null);

        // Shader program set
        glUseProgram(this.shaderProgram);

        // internal OpenGL ID of a shader uniform (constant during one draw call
        // - constant value for all processed vertices or pixels) variable
        //locTime = glGetUniformLocation(shaderProgram, "time");
        locMath = glGetUniformLocation(shaderProgram, "MVP");
    }

    void createBuffers() {

        BufferGenerator buf = new BufferGenerator();

        int m = 10;
        int n = 10;

        buf.createVertexBuffer(m, n);
        buf.createIndexBuffer(m , n);

        float[] vertexBufferData = buf.getVertexBufferData();
        int[] indexBufferData = buf.getIndexBufferData();

        /*for(int j = 0; j < vertexBufferData.length; j+=8) {
            for (int i = j; i < m * 2 + j; i++) {
                System.out.print(vertexBufferData[i] + "  ");
            }
            System.out.println();
            System.out.println();
        }*/

        for(int i = 0; i < indexBufferData.length; i++){
            System.out.print(indexBufferData[i] + "  ");
        }

        // vertex binding description, concise version
        OGLBuffers.Attrib[] attributes = {
                new OGLBuffers.Attrib("inPosition", 2), // 2 floats
                //new OGLBuffers.Attrib("inColor", 3) // 3 floats
        };
        buffers = new OGLBuffers(vertexBufferData, attributes,
                indexBufferData);
    }

    private void loop() {
        // Run the rendering loop until the user has attempted to close
        // the window or has pressed the ESCAPE key.
        while ( !glfwWindowShouldClose(window) ) {

            glViewport(0, 0, width, height);

            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); // clear the framebuffer

            // set the current shader to be used, could have been done only once (in
            // init) in this sample (only one shader used)
            glUseProgram(shaderProgram);
            // to use the default shader of the "fixed pipeline", call
            // glUseProgram(0);
            time += 0.01;
            glUniformMatrix4fv(locMath, false, mvp.mul(new Mat4RotX(time)).floatArray());
            //glUniform1f(locTime, time); // correct shader must be set before this

            // bind and draw
            //buffers.draw(GL_TRIANGLES, shaderProgram);

            glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
            // bind and draw
            buffers.draw(GL_TRIANGLES, shaderProgram);

            glfwSwapBuffers(window); // swap the color buffers

            // Poll for window events. The key callback above will only be
            // invoked during this call.
            glfwPollEvents();
        }
    }

    public void run() {
        try {
            System.out.println("Hello LWJGL " + Version.getVersion() + "!");
            init();

            loop();

            // Free the window callbacks and destroy the window
            glfwFreeCallbacks(window);
            glfwDestroyWindow(window);

        } catch (Throwable t) {
            t.printStackTrace();
        } finally {
            // Terminate GLFW and free the error callback
            glDeleteProgram(shaderProgram);
            glfwTerminate();
            glfwSetErrorCallback(null).free();
        }

    }

    public static void main(String[] args) {
        new App().run();
    }
}
