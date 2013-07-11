import java.util.Arrays;

public class FoxAndVacation {

	public int maxCities(int total, int[] d) {
		Arrays.sort(d);
		int c=0;
		for(int i=0;i<d.length;i++){
			if(total>=d[i]){
				total-=d[i];
				c++;
			}
		}
		return c;
	}

}
