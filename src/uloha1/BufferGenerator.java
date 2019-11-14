package uloha1;

public class BufferGenerator {

    float[] vertexBufferData = {};
    int[] indexBufferData = {};

    public float[] getVertexBufferData() {
        return vertexBufferData;
    }

    public int[] getIndexBufferData() {
        return indexBufferData;
    }

    public BufferGenerator() {
    }

    // metoda pro generování vertex bufferu
    public void createVertexBuffer(int m, int n) {

        vertexBufferData = new float[m*n*2];
        //vertexBufferData[0] = 0;

        float interval = (float) 1/(m-1);

        float x = 0;
        float y = 0;

        for(int i = 0; i < m*n*2; i+=m*2) {
            for(int j = i; j < n*2+i-1; j+=2) {
                vertexBufferData[j] = x;
                vertexBufferData[j+1] = y;
                x+=interval;
            }
            y+=interval;
            x = 0;
        }
    }

    // metoda pro vytvoření index bufferu pro vykreslení pomocí GL_TRIANGLES
    public void createIndexBuffer(int m, int n) {
        // 0,5,6,0,6,1,1,6,7,1,7,2,2,7,8,2,8,3,3,8,9,3,9,4....

        indexBufferData = new int[6*(m-1)*(n-1)];
        int i = 0;
        int k;
        for(int y = 0; y < n - 1; y++) {
            for(int x = 0; x < m - 1; x++) {
                k = x + y*m;
                indexBufferData[i++] = k;
                indexBufferData[i++] = k + 1;
                indexBufferData[i++] = k + (m+1);
                indexBufferData[i++] = k;
                indexBufferData[i++] = k + (m+1);
                indexBufferData[i++] = k + m;
            }
        }
    }

    // metoda pro vytvoření index bufferu pro vykreslení pomocí GL_TRIANGLE_STRIP (použití degenerovaných trojuhelníků)
    public void createIndexBufferTriangleStrips(int m, int n) {
        // výpočet velikosti pole
        final int numOfTriangleStrips = n - 1;
        final int numOfDegenTriangles = 2 * (numOfTriangleStrips - 1);
        final int verticesPerStrip = 2 * m;
        indexBufferData = new int[(verticesPerStrip * numOfTriangleStrips)
                + numOfDegenTriangles];

        // naplnění index bufferu
        int i = 0;
        for(int y = 0; y < n - 1; y++) {
            if(y > 0) {
                indexBufferData[i++] = y * n;
            }
            for(int x = 0; x < m; x++) {
                indexBufferData[i++] = (y * n) + x;
                indexBufferData[i++] = ((y+1) * n) + x;
            }

            if(y < n - 2) {
                indexBufferData[i++] = ((y+1) * n) + (m - 1);
            }
        }
    }
}
