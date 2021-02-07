
public class ECA {
   public final int rule;
   public final int boundary;
   public final int rowCount;
   private final int[] cells;
   private boolean hasComputed;
   
   public int applyRule(int rule, int l, int m, int r) {
     if (l < 0 || l > 1 || m < 0 || m > 1 || r < 0 || r > 1)
       throw new IllegalArgumentException();
     return (rule >> (l << 2 + m << 1 + r)) & 1;
   }
   
   private int applyRule(int l, int m, int r) {
     int result = (rule >> ((l << 2) + (m << 1) + r)) & 1;
     return result; //<>//
   }

   private boolean hasCell(int row, int col) {
     return (col >= -row && col <= row); 
   }

  private int casize(int rowCount) {
      return rowCount * rowCount;
  }
  
  /* CELL INDEXING:
 ... -2 -1  0  1  2  ... col
 0|         0
 1|      1  2  3
 2|   4  5  6  7  8
 .        ...
 .
 .
 row
*/
  private int index(int row, int col) {
    return casize(row) + col + row; //row is offset
  }
  
  //computes the next value of the given cell and fills it into the cell array
  private void next(int row, int col) { 
      int l = hasCell(row-1, col-1) ? cells[index(row-1,col-1)] : boundary;
      int m = hasCell(row-1, col) ? cells[index(row-1,col)] : boundary;
      int r = hasCell(row-1, col+1) ? cells[index(row-1,col+1)] : boundary;
      cells[index(row, col)] = applyRule(l, m, r); //<>//
  }
  
  private void compute() {
      for (int row = 1; row < rowCount; row++)
         for (int col = -row; col <= row; col++)
             next(row, col);
      hasComputed = true;
  }
  
  public ECA(int rule, int boundary, int rowCount, int initVal) {
     if (boundary < 0 || boundary > 1 || rowCount < 1)
       throw new IllegalArgumentException();
      this.rule = rule;
      this.boundary = boundary;
      this.cells = new int[casize(rowCount)];
      this.cells[0] = initVal;
      this.hasComputed = false;
      this.rowCount = rowCount;
  }
  
  public int getCellVal(int row, int col) {
     if (!hasCell(row, col))
       return boundary;
     int i = index(row, col);
     if (i < 0 || i >= cells.length)
       throw new IllegalArgumentException();
     if (!hasComputed)
       compute();
     return cells[i];
  }
  
  public int[][] getCellRange(int startRow, int endRow, int startCol, int endCol) {
      if (startRow < 0 || endRow > rowCount)
        throw new IllegalArgumentException();
      if (!hasComputed)
        compute();
      int[][] result = new int[endRow - startRow][endCol - startCol];
      for (int row = startRow; row < endRow; row++)
         for  (int col = max(-row, startCol); col < min(row, endCol); col++)
           result[row - startRow][col - startCol] = cells[index(row,col)];
      return result;
  }
  
  public PImage makeImage(int startRow, int endRow, int startCol, int endCol, color color0, color color1) {
      int width = endCol - startCol, height = endRow - startRow;
      if (startRow < 0 || endRow > rowCount || height <= 0 || width <= 0)
        throw new IllegalArgumentException();
      if (!hasComputed)
        compute();
      PImage img = createImage(width, height, RGB);
      img.loadPixels();
      for (int i = 0; i < width; i++)
        for (int j = 0; j < height; j++)
            img.pixels[j*width + i] = boundary == 1 ? color1 : color0;
      for (int row = startRow; row < endRow; row++)
         for  (int col = max(-row, startCol); col < min(row+1, endCol); col++) {
           int pixelIndex = (row-startRow)*width + col - startCol;
           img.pixels[pixelIndex] = cells[index(row,col)] == 1 ? color1 : color0; //assume row major order
         }
      img.updatePixels();
      return img;
  }
  
}

//interesting rule: 45, 73, 75
void mkImg(int rule, int boundary, int initval, int row, int col, int w, int h) {
    ECA a = new ECA(rule, boundary, row + h, initval);
    PImage img = a.makeImage(row, row+h, col, col+w, color(255,255,255), color(0,0,0));
    String filename = "r" + rule + "_b" + boundary + "_i" + initval + "_x" + col + "_y" + row + "_w" + w + "_h" + h + ".png";
    img.save(filename); 
    image(img, 0, 0);
}

void mkCenteredImg(int rule, int boundary, int initval, int w, int h) {
    mkImg(rule, boundary, initval, w / 2, -w/2, w, h);
}

void mkLeftImg(int rule, int boundary, int initval, int w, int h, float c) {
   if (c <= 0 || c > 1) 
     throw new IllegalArgumentException();
   int row = ceil((((float)w / c) - 1.0) * 0.5);
   mkImg(rule, boundary, initval, row, -row, w, h);
}

void mkRightImg(int rule, int boundary, int initval, int w, int h, float c) {
   if (c <= 0 || c > 1) 
     throw new IllegalArgumentException();
   int row = ceil((((float)w / c) - 1.0) * 0.5);
   mkImg(rule, boundary, initval, row, row-w, w, h);
}


final int[] complexRules = {30, 45, 73, 75, 86, 89, 101, 110, 124, 135, 137, 149, 151, 169, 193, 225};
void setup() {
  size(1920, 1080);
  background(200);
  //for (int rule = 0; rule < 256; rule++)
  //  mkImg(rule, 0, 1, 200, -200, 400, 400);
  //for (int rule : complexRules)
  //  mkCenteredImg(rule, 0, 1, 2560, 1440);
  mkLeftImg(151, 0, 1, 1440, 2560, 0.3);
}
