import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class EasyHomeworkTest {

    protected EasyHomework solution;

    @Before
    public void setUp() {
        solution = new EasyHomework();
    }

    @Test(timeout = 2000)
    public void testCase0() {
        int[] A = new int[]{5, 7, 2};

        String expected = "POSITIVE";
        String actual = solution.determineSign(A);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase1() {
        int[] A = new int[]{-5, 7, 2};

        String expected = "NEGATIVE";
        String actual = solution.determineSign(A);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase2() {
        int[] A = new int[]{5, 7, 2, 0};

        String expected = "ZERO";
        String actual = solution.determineSign(A);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase3() {
        int[] A = new int[]{3, -14, 159, -26};

        String expected = "POSITIVE";
        String actual = solution.determineSign(A);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase4() {
        int[] A = new int[]{-1000000000};

        String expected = "NEGATIVE";
        String actual = solution.determineSign(A);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase5() {
        int[] A = new int[]{123, -456, 789, -101112, 131415, 161718, 192021, 222324, 252627, 282930, 313233, 343536, 373839, 404142, 434445, 464748, 495051, 525354, 555657};

        String expected = "POSITIVE";
        String actual = solution.determineSign(A);

        Assert.assertEquals(expected, actual);
    }

}
