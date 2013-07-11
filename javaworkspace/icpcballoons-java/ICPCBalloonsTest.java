import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

public class ICPCBalloonsTest {

    protected ICPCBalloons solution;

    @Before
    public void setUp() {
        solution = new ICPCBalloons();
    }

    @Test(timeout = 2000)
    public void testCase0() {
        int[] balloonCount = new int[]{100};
        String balloonSize = "L";
        int[] maxAccepted = new int[]{1, 2, 3, 4, 5};

        int expected = 10;
        int actual = solution.minRepaintings(balloonCount, balloonSize, maxAccepted);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase1() {
        int[] balloonCount = new int[]{100};
        String balloonSize = "M";
        int[] maxAccepted = new int[]{10, 20, 30, 40, 50};

        int expected = -1;
        int actual = solution.minRepaintings(balloonCount, balloonSize, maxAccepted);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase2() {
        int[] balloonCount = new int[]{5, 6, 1, 5, 6, 1, 5, 6, 1};
        String balloonSize = "MLMMLMMLM";
        int[] maxAccepted = new int[]{7, 7, 4, 4, 7, 7};

        int expected = 6;
        int actual = solution.minRepaintings(balloonCount, balloonSize, maxAccepted);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase3() {
        int[] balloonCount = new int[]{100, 100};
        String balloonSize = "ML";
        int[] maxAccepted = new int[]{50, 51, 51};

        int expected = -1;
        int actual = solution.minRepaintings(balloonCount, balloonSize, maxAccepted);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase4() {
        int[] balloonCount = new int[]{8, 5, 1, 4, 1, 1, 3, 1, 3, 3, 5, 4, 5, 6, 9};
        String balloonSize = "MMMLLLMMLLMLMLM";
        int[] maxAccepted = new int[]{3, 5, 3, 3, 5, 6, 4, 6, 4, 2, 3, 7, 1, 5, 2};

        int expected = 5;
        int actual = solution.minRepaintings(balloonCount, balloonSize, maxAccepted);

        Assert.assertEquals(expected, actual);
    }

    @Test(timeout = 2000)
    public void testCase5() {
        int[] balloonCount = new int[]{1, 18, 4, 7, 19, 7, 7, 1, 4, 8, 10, 5, 14, 13, 8, 22, 6, 3, 13, 5, 3, 4, 2, 1, 3, 15, 19, 4, 5, 9, 4, 11, 2, 7, 12, 20, 11, 26, 22, 7, 2, 10, 9, 20, 13, 20, 2, 9, 11, 9};
        String balloonSize = "LLMLLLLMLLLLLLLLLLLLMLLLLLLLLLLMMLMLLLMLLLLLLLLMLL";
        int[] maxAccepted = new int[]{44, 59, 29, 53, 16, 23, 13, 14, 29, 42, 13, 15, 66, 4, 47};

        int expected = 210;
        int actual = solution.minRepaintings(balloonCount, balloonSize, maxAccepted);

        Assert.assertEquals(expected, actual);
    }

}
