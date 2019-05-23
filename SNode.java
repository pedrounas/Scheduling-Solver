import java.util.HashMap;
import java.util.Map;
import java.lang.*;
public class SNode{
    int nodeNR;
    int EStart;
    int EFinish;
    int LStart;
    int LFinish;
    int duration;
    int nrTrab;
    boolean critTask;
    boolean visited;
    HashMap<Integer,Boolean> precedences;
    int curStart;
    static int maxDuration;


    public SNode(int nodeNR, int EStart, int EFinish, int LStart, int LFinish, int duration, int nrTrab, boolean critTask, boolean visited, HashMap<Integer, Boolean> precedences, int curStart) {
        this.nodeNR = nodeNR;
        this.EStart = EStart;
        this.EFinish = EFinish;
        this.LStart = LStart;
        this.LFinish = LFinish;
        this.duration = duration;
        this.nrTrab = nrTrab;
        this.critTask = critTask;
        this.visited = visited;
        this.precedences = precedences;
        this.curStart = curStart;
    }

    public SNode(int nodeNR, HashMap<Integer,Boolean> precedences, int duration, int nrTrab){
        this.nodeNR =nodeNR;
        this.EStart = 0;
        this.EFinish = 0;
        this.LStart = 0;
        this.LFinish = 0;
        this.duration = duration;
        this.precedences = precedences;
        this.nrTrab = nrTrab;
        this.critTask = false;
        this.visited = false;
        this.curStart= 0;
    }

    public int getCurStart() {
        return this.curStart;
    }

    public void setCurStart(int curStart) {
        this.curStart = curStart;
    }

    public boolean isCritTask() {
        return critTask;
    }

    public int getLStart() {
        return LStart;
    }

    public void setLStart() {
        this.LStart = this.LFinish-this.duration;
    }

    public int getLFinish() {
        return LFinish;
    }

    public void setLFinish(int LFinish) {
        this.LFinish = LFinish;
    }

    public void setCritTask() {
        this.critTask = true;
    }

    public int getEStart(){
        return this.EStart;
    }

    public int getNodeNR(){
        return this.nodeNR;
    }
    public int getEFinish(){
        return this.EFinish;
    }
    public int getDuration(){
        return this.duration;
    }
    public HashMap<Integer,Boolean> getPrecedences(){
        return this.precedences;
    }
    public int getNrTrab(){
        return this.nrTrab;
    }
    public void setEStart(int estart){
        this.EStart = estart;
        this.curStart = estart;
    }
    public void setEFinish(int efin){
        this.EFinish = efin;
    }
    public void addSetEFinish(){
        this.EFinish = this.duration + this.EStart;
    }
    public void setVisited(){
        this.visited = true;
    }
    public boolean getVisited(){
        return this.visited;
    }

    public void printNode(){//uses this
        System.out.println("nodeNR = " + this.nodeNR + " duration =" + this.duration + " nrtrab = " + this.nrTrab);
        System.out.print("precedences: ");
        for(Map.Entry<Integer, Boolean> entry : this.precedences.entrySet()) {
            int key = entry.getKey();
            System.out.print(key + " ");
        }
        System.out.println();
        System.out.println("EStart = " + this.EStart +" EFinish =" + this.EFinish);
        System.out.println("LStart = " + this.LStart +" LFinish =" + this.LFinish);
        if(isCritTask()){
            System.out.println("Is Crit Task");
        }
        System.out.println("optimizedStart = " + this.curStart);
        System.out.println();
    }

    public void setUnVisited() {
        this.visited = false;
    }

    public void incrementCurStart() {
        this.curStart++;
    }

    public SNode copyOf() {
        SNode copy =new SNode(this.nodeNR, this.EStart, this.EFinish, this.LStart, this.LFinish, this.duration, this.nrTrab, this.critTask, this.visited, this.precedences, this.curStart);
        return copy;
    }
}
