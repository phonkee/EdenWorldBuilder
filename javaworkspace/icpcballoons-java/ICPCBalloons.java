public class ICPCBalloons {

	public int minRepaintings(int[] balloonCount, String balloonSize, int[] maxAccepted) {
		int m=0;
		int l=0;
		for(int i=0;i<balloonCount.length;i++){
			if(balloonSize.charAt(i)=='L')
			l+=balloonCount[i];
			else
				m+=balloonCount[i];
		}
		return 0;
	}

}
