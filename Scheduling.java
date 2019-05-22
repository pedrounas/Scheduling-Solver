import java.util.*;
import java.lang.*;
import java.io.*;

public class Scheduling{
    public static int min;
    public static int alternateSolutions;
    public static void main(String... args){
        LinkedList<SNode> nodeList = null;
        try{
            nodeList = readData();
        }
        catch(IOException e){}
       // printList(nodeList);
        nodeList = runList(nodeList);
        printList(nodeList);

         analyseList(nodeList);
    }
    public static void printList(LinkedList<SNode> nodeList){
        for(int i=0; i<nodeList.size(); i++){
            nodeList.get(i).printNode();
        }
    }
    public static void analyseList(LinkedList<SNode> nodeList){
        int maxTime = getMaxFinish(nodeList);
        System.out.println("Max duration for the project: " + maxTime);
        int maxWorkers = getMaxWorkers(nodeList, false);
        System.out.println("Max workers for min duration is: " + maxWorkers);
        identifyCriticalPath(nodeList);
        int maxWorkersCrit = getMaxWorkers(nodeList, true);
        System.out.println("Workers for crit path is: " + maxWorkersCrit);
        LinkedList<SNode> bestList = getOptimizeValue(nodeList, maxWorkers);
        System.out.println("menor numero de trabalhadores otimizado é" + min + "e a sua lista é");
        printList(bestList);
        if(alternateSolutions>0) System.out.println("Existem soluções alternativas");
        else System.out.println("Não existem soluções alternativas");



    }

    private static int getMaxFinish(LinkedList<SNode> nodeList) {
        SNode cur = null;
        int max= 0;
        for(int i=0; i<nodeList.size(); i++){
            cur = nodeList.get(i);
            if(cur.getEFinish()>max)
                max = cur.getEFinish();
        }
        return max;
    }

    private static void identifyCriticalPath(LinkedList<SNode> nodeList) {
        SNode cur = null;
        for(int i=0; i<nodeList.size(); i++){
            cur = nodeList.get(i);
            if(cur.getEStart()  == cur.getLStart()){
                cur.setCritTask();
            }
        }
    }

    private static LinkedList<SNode> getOptimizeValue(LinkedList<SNode> nodeList, int maxWorkers){
        PriorityQueue<SNode> pq = getPriorityQueue(nodeList);
        LinkedList<SNode> testList = new LinkedList<>();
        LinkedList<SNode> bestList = new LinkedList<>();
        min = maxWorkers;
        bestList = expandPriorityQueue(pq, testList, bestList);
        return bestList;
    }

    private static PriorityQueue<SNode> getPriorityQueue(LinkedList<SNode> nodeList) {
        PriorityQueue<SNode> pq = new PriorityQueue<SNode>(new SNodeComparator());
        SNode cur;
        for(int i = 0; i<nodeList.size(); i++){
            cur = nodeList.get(i);
            if(!cur.isCritTask())
                pq.add(nodeList.get(i));
        }
        return pq;
    }

    private static LinkedList<SNode> expandPriorityQueue(PriorityQueue<SNode> pq, LinkedList<SNode> testList, LinkedList<SNode> bestList) {
        if(pq.isEmpty()){
            int max = getMaxWorkers(testList, false);
            if (max>min){
                return bestList;
            }
            else if(max == min){
                alternateSolutions=1;
                return bestList;
            }
            min = max;
            bestList = copyList(testList);
        }
        else {
            SNode atual = pq.poll();
            int availableStartDay = getStartDay(testList, atual);
            atual.setCurStart(availableStartDay);
            while (atual.getCurStart() < atual.getLStart()) {

                testList.add(atual);
                bestList = expandPriorityQueue(pq, testList, bestList);
                testList.remove(atual);
                atual.incrementCurStart();
            }
            pq.add(atual);
        }
        return bestList;
    }

    private static LinkedList<SNode> copyList(LinkedList<SNode> testList) {
        LinkedList<SNode> clone = new LinkedList<>();
        SNode cur;
        for (int i=0; i<testList.size(); i++){
            cur = testList.get(i);
            clone.addLast(cur.copyOf());
        }
        return clone;
    }

    private static int getStartDay(LinkedList<SNode> testList, SNode atual) {
        int available, curNodeNr;
        Boolean isPrecedent;
        SNode cur;
        HashMap<Integer,Boolean> hm = atual.getPrecedences();
        available = atual.getEStart();
        for (int i=0; i<testList.size(); i++){
            cur = testList.get(i);
            curNodeNr = cur.getNodeNR();
            isPrecedent = hm.get(curNodeNr);
            if(isPrecedent!=null){
                if (cur.getCurStart()>available){
                    available = cur.getCurStart();
                }
            }
        }
        return available;
    }

    private static int getMaxWorkers(LinkedList<SNode> nodeList, Boolean considerOnlyCritPath) {
        SNode cur;
        int maxTime = getMaxFinish(nodeList);
        int[] time = new int[maxTime+1];
        for (int i=0; i<nodeList.size(); i++){
              cur = nodeList.get(i);
              if(considerOnlyCritPath && !cur.isCritTask())
                  continue;
              for(int j = cur.getEStart(); j<cur.getEFinish(); j++){
                  time[j] = time[j]+cur.getNrTrab();
              }
        }
        return getMax(time);
    }

    private static int getMax(int[] time) {
        int max = 0;
        for(int i=0; i<time.length; i++){
            if(time[i]>max){
                max = time[i];
            }
        }
        return max;
    }

    public static LinkedList<SNode> readData() throws IOException{
        BufferedReader reader = new BufferedReader(new FileReader("data.txt"));
        LinkedList<SNode> nodeList = new LinkedList<SNode>();
        String line=null;
        String[] parts;
        int starterFlag=0;
        int nodeNR, duracao, nrTrab, size, nrPrec;
        line = reader.readLine();
        while (( line = reader.readLine()) != null){
            parts = line.split(" ");
            size = parts.length;
            nrPrec=Integer.parseInt(parts[1]);

            nodeNR = Integer.parseInt(parts[0]);
            //System.out.println(Integer.parseInt(parts[size]));
            HashMap<Integer,Boolean> hm = new HashMap<Integer,Boolean>(6);
            if(nrPrec==0){
                hm.put(0, false);
                starterFlag=1;
            }
            for(int i=0; i<nrPrec; i++){
                    hm.put(Integer.parseInt(parts[i+2]), true);
                }
            duracao = Integer.parseInt(parts[size-2]);
            nrTrab =Integer.parseInt(parts[size-1]);
            SNode node = new SNode(nodeNR, hm, duracao, nrTrab);
            if (starterFlag==1){
                node.addSetEFinish();
                starterFlag = 0;
            }
            nodeList.addLast(node);
        }
        return nodeList;
    }

    public static LinkedList<SNode> runList(LinkedList<SNode> nodeList){
        nodeList = forwardPass(nodeList);
        nodeList = backwardPass(nodeList);
        return nodeList;
    }

    private static LinkedList<SNode> backwardPass(LinkedList<SNode> nodeList) {
        int[] grauS = getNodeGrau(nodeList);
        Queue<SNode> S = getGrau0(grauS, nodeList);
        SNode precedent = null;
        SNode cur =S.poll();//not initializing as null becuz of while
        while(cur!=null){
            for (Map.Entry<Integer, Boolean> entry : cur.precedences.entrySet()) {
                if(entry.getKey()!=0) {
                    precedent = nodeList.get(entry.getKey() - 1);
                    updateLF(cur, precedent);
                    grauS[precedent.getNodeNR()-1]--;
                    if (grauS[precedent.getNodeNR()-1] == 0)
                        S.add(precedent);
                }
            }
            cur = S.poll();
        }
        return nodeList;
    }

    private static void updateLF(SNode cur, SNode precedent) {
        if(cur.getLStart()<precedent.getLFinish() || precedent.getLFinish()==0){
            precedent.setLFinish(cur.getLStart());
            precedent.setLStart();
        }
    }

    private static LinkedList<SNode> getGrau0(int[] grauS, LinkedList<SNode> nodeList) {
        LinkedList<SNode> queue = new LinkedList<>();
        SNode cur = null;
        for(int i=0; i<grauS.length;i++){
            if(grauS[i]==0){
                cur = nodeList.get(i);
                cur.setLFinish(cur.getEFinish());
                cur.setLStart();
                queue.add(cur);
            }
        }
        return queue;
    }

    private static int[] getNodeGrau(LinkedList<SNode> nodeList) {
        SNode cur = null;
        int[] grau = new int[nodeList.size()];
        for(int i=0; i< nodeList.size(); i++){
            cur = nodeList.get(i);
            for (Map.Entry<Integer, Boolean> entry : cur.precedences.entrySet()) {
                if(entry.getKey()!=0)
                    grau[entry.getKey()-1]++;
            }
        }
        return grau;
    }

    private static LinkedList<SNode> forwardPass(LinkedList<SNode> nodeList) {
        SNode cur = getNextNode(nodeList);
        while(cur!=null){
            nodeList = checkPrecedences(cur, nodeList);
            cur = getNextNode(nodeList);
        }
        return nodeList;
    }

    public static SNode getNextNode(LinkedList<SNode> nodeList){
        for (int i=0; i<nodeList.size(); i++) {
            SNode cur = nodeList.get(i);
            if(!cur.getPrecedences().containsValue(true) && !cur.getVisited()){//if all precedences value are false than pick it
                cur.setVisited();
                return cur;
            }
        }
        return null;
    }

    public static LinkedList<SNode> checkPrecedences(SNode ref, LinkedList<SNode> nodeList){
        for(int i=0; i<nodeList.size(); i++){
            SNode cur = nodeList.get(i);
            boolean  hasNode= cur.getPrecedences().containsKey(ref.getNodeNR());
            if( hasNode){
                updateES(cur, ref);
                removePrecedences(cur, ref);
            }
        }
        return nodeList;
    }

    public static void updateES(SNode cur, SNode ref){//if ES is worse, change it
        if(cur.getEStart()<ref.getEFinish()){
            cur.setEStart(ref.getEFinish());
            cur.addSetEFinish();
        }
    }

    public static void removePrecedences(SNode cur, SNode ref){
        cur.getPrecedences().replace(ref.getNodeNR(), false);
    }
}
class SNodeComparator implements Comparator<SNode>{

    @Override
    public int compare(SNode o1, SNode o2) {
        int s1 = getSlack(o1);
        int s2 = getSlack(o2);
        if(s1>s2){
            return -1;
        }
        else if(s1<s2){
            return 1;
        }
        else return 0;
    }

    private int getSlack(SNode o1) {
        return o1.EFinish - o1.LFinish;
    }
}
