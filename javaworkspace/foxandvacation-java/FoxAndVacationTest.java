import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class FoxAndVacationTest {

    protected FoxAndVacation solution;

    @Before
    public void setUp() {
        solution = new FoxAndVacation();
    }

    @Test(timeout = 2000)
    public void testCase0() {
        int total = 5;
        int[] d = new int[]{2, 2, 2};

        int expected = 2;
        int actual = solution.maxCities(total, d);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase1() {
        int total = 5;
        int[] d = new int[]{5, 6, 1};

        int expected = 1;
        int actual = solution.maxCities(total, d);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase2() {
        int total = 5;
        int[] d = new int[]{6, 6, 6};

        int expected = 0;
        int actual = solution.maxCities(total, d);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase3() {
        int total = 6;
        int[] d = new int[]{1, 1, 1, 1, 1};

        int expected = 5;
        int actual = solution.maxCities(total, d);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase4() {
        int total = 10;
        int[] d = new int[]{7, 1, 5, 6, 1, 3, 4};

        int expected = 4;
        int actual = solution.maxCities(total, d);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase5() {
        int total = 50;
        int[] d = new int[]{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};

        int expected = 9;
        int actual = solution.maxCities(total, d);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase6() {
        int total = 21;
        int[] d = new int[]{14, 2, 16, 9, 9, 5, 5, 23, 25, 20, 8, 25, 6, 12, 3, 2, 4, 5, 10, 14, 19, 12, 25, 15, 14};

        int expected = 6;
        int actual = solution.maxCities(total, d);

        Assert.assertEquals(expected, actual);
    }

}
