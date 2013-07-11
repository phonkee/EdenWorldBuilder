import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class RobotHerbDiv2Test {

    protected RobotHerbDiv2 solution;

    @Before
    public void setUp() {
        solution = new RobotHerbDiv2();
    }

    @Test(timeout = 2000)
    public void testCase0() {
        int T = 1;
        int[] a = new int[]{1, 2, 3};

        int expected = 2;
        int actual = solution.getdist(T, a);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase1() {
        int T = 100;
        int[] a = new int[]{1};

        int expected = 0;
        int actual = solution.getdist(T, a);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase2() {
        int T = 5;
        int[] a = new int[]{1, 1, 2};

        int expected = 10;
        int actual = solution.getdist(T, a);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase3() {
        int T = 100;
        int[] a = new int[]{400000};

        int expected = 40000000;
        int actual = solution.getdist(T, a);

        Assert.assertEquals(expected, actual);
    }

}
