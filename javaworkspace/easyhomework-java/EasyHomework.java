public class EasyHomework {

	public String determineSign(int[] A) {
		int n=1;
		for(int i=0;i<A.length;i++){
			if(A[i]==0)n*=0;
			if(A[i]>0)n*=1;
			if(A[i]<0)n*=-1;
		}
		if(n==0)return "ZERO";
		if(n<0)return "NEGATIVE";
		if(n>0)return "POSITIVE";
		return null;
	}

}
