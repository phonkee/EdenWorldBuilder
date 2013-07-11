import java.util.*;
public class Suminator {

	public int findMissing(int[] program, int wantedResult) {
		ArrayList<Long> stack=new ArrayList<Long>();
		
		for(int i=0;i<500;i++)stack.add((long)0);
		for(int i=0;i<program.length;i++){
			if(program[i]!=0||program[i]!=-1){
				stack.add(0,(long) program[i]);
			}else if(program[i]==0){
				long n=stack.remove(0);
				long n2=stack.remove(2);
				
				stack.add(0,n+n2);
			}else if(program[i]==0){
				stack.add(-10000,(long)0);
			}
		}
		long w=stack.remove(0);
		
		return 0;
	}

}
