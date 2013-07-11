import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class ChopsticksTest {

    protected Chopsticks solution;

    @Before
    public void setUp() {
        solution = new Chopsticks();
    }

    @Test(timeout = 2000)
    public void testCase0() {
        int[] length = new int[]{5, 5};

        int expected = 1;
        int actual = solution.getmax(length);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase1() {
        int[] length = new int[]{1, 2, 3, 2, 1, 2, 3, 2, 1};

        int expected = 4;
        int actual = solution.getmax(length);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase2() {
        int[] length = new int[]{1};

        int expected = 0;
        int actual = solution.getmax(length);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase3() {
        int[] length = new int[]{1, 2, 3, 4, 5, 6, 7, 8, 9};

        int expected = 0;
        int actual = solution.getmax(length);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase4() {
        int[] length = new int[]{35, 35, 35, 50, 16, 30, 10, 10, 35, 50, 16, 16, 16, 30, 50, 30, 16, 35, 50, 30, 10, 50, 50, 16, 16, 10, 35, 50, 50, 50, 16, 35, 35, 30, 35, 10, 50, 10, 50, 50, 16, 30, 35, 10, 10, 30, 10, 10, 16, 35};

        int expected = 24;
        int actual = solution.getmax(length);

        Assert.assertEquals(expected, actual);
    }

}
