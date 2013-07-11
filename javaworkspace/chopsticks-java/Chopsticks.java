public class Chopsticks {

	public int getmax(int[] length) {
		int[] sticks=new int[101];
		for(int i=0;i<length.length;i++){
			sticks[length[i]]++;
		}
		int c=0;
		for(int i=0;i<sticks.length;i++){
			c+=sticks[i]/2;
		}
		return c;
	}

}
