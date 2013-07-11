import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class MegaFactorialDiv2Test {

    protected MegaFactorialDiv2 solution;

    @Before
    public void setUp() {
        solution = new MegaFactorialDiv2();
    }

    @Test(timeout = 2000)
    public void testCase0() {
        int N = 3;
        int K = 1;

        int expected = 4;
        int actual = solution.countDivisors(N, K);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase1() {
        int N = 3;
        int K = 2;

        int expected = 6;
        int actual = solution.countDivisors(N, K);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase2() {
        int N = 4;
        int K = 2;

        int expected = 18;
        int actual = solution.countDivisors(N, K);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase3() {
        int N = 6;
        int K = 3;

        int expected = 1392;
        int actual = solution.countDivisors(N, K);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase4() {
        int N = 100;
        int K = 2;

        int expected = 321266186;
        int actual = solution.countDivisors(N, K);

        Assert.assertEquals(expected, actual);
    }

}
