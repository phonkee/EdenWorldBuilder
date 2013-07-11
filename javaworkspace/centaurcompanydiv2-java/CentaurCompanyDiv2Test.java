import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class CentaurCompanyDiv2Test {

    protected CentaurCompanyDiv2 solution;

    @Before
    public void setUp() {
        solution = new CentaurCompanyDiv2();
    }

    @Test(timeout = 2000)
    public void testCase0() {
        int[] a = new int[]{1};
        int[] b = new int[]{2};

        long expected = 4L;
        long actual = solution.count(a, b);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase1() {
        int[] a = new int[]{2, 2};
        int[] b = new int[]{1, 3};

        long expected = 7L;
        long actual = solution.count(a, b);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase2() {
        int[] a = new int[]{1, 2, 3, 4, 5, 6, 7, 8, 9};
        int[] b = new int[]{2, 3, 4, 5, 6, 7, 8, 9, 10};

        long expected = 56L;
        long actual = solution.count(a, b);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase3() {
        int[] a = new int[]{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};
        int[] b = new int[]{2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51};

        long expected = 1125899906842675L;
        long actual = solution.count(a, b);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase4() {
        int[] a = new int[]{10, 7, 2, 5, 6, 2, 4, 9, 7};
        int[] b = new int[]{8, 10, 10, 4, 1, 6, 2, 2, 3};

        long expected = 144L;
        long actual = solution.count(a, b);

        Assert.assertEquals(expected, actual);
    }

}
