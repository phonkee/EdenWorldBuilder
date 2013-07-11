import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class FenceRepairingTest {

    protected FenceRepairing solution;

    @Before
    public void setUp() {
        solution = new FenceRepairing();
    }

    public static void assertEquals(double expected, double actual) {
        if (Double.isNaN(expected)) {
            Assert.assertTrue("expected: <NaN> but was: <" + actual + ">", Double.isNaN(actual));
            return;
        }
        double delta = Math.max(1e-9, 1e-9 * Math.abs(expected));
        Assert.assertEquals(expected, actual, delta);
    }

    @Test(timeout = 2000)
    public void testCase0() {
        String[] boards = new String[]{"X.X...X.X"};

        double expected = 3.0;
        double actual = solution.calculateCost(boards);

        assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase1() {
        String[] boards = new String[]{"X.X.....X"};

        double expected = 2.732050807568877;
        double actual = solution.calculateCost(boards);

        assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase2() {
        String[] boards = new String[]{"X.......", "......XX", ".X......", ".X...X.."};

        double expected = 5.0;
        double actual = solution.calculateCost(boards);

        assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase3() {
        String[] boards = new String[]{".X.......X", "..........", "...X......", "...X..X...", "..........", "..........", "..X....XX.", ".........X", "XXX", ".XXX.....X"};

        double expected = 9.591663046625438;
        double actual = solution.calculateCost(boards);

        assertEquals(expected, actual);
    }

}
