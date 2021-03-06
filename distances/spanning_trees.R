### Function for computing spanning trees in graphs

library('Matrix')
library(igraph)


#### Computes spanning tree distance. Makes adjustments if the graph becomes
#### disconnected.



###  --------------------------------------------------------
get_number_spanning_trees<-function(A,adjust_disconnection=TRUE,verbose=FALSE){
  ## A is the adjacency matrix of the graph
  ### Note that this works only if the graph is completely connected. Otherwise, it seems even a little meaningless.
  #A<-as.matrix(A)
  N=nrow(A)
  if (length(A)>1){
    D<-apply(A,1,sum)  ### degree (diagonal should be the degree of each node)
  }
  else{
    return(1)
  }

  if (sum(D==0)>0 & verbose ) print(paste("isolated node(s): ",which(D==0)))
  
  #### This block takes care of isolated nodes
  if (sum(which(D==0))>0 && N>2 && adjust_disconnection==TRUE){  ## adjust the disconnection
    index=which(D==0)
    index_connected<-setdiff(1:ncol(A),index)
    A<-A[index_connected,index_connected]
    return(get_number_spanning_trees(A,adjust_disconnection=TRUE))
  }
  #### We now have to take care of isolated blocks
  else{
    if(N<3){
        nb=ifelse(sum(diag(D))==0,0,1) ## 2 nodes= 1 ST
    }
    else{

        D<-apply(A,1,sum)
        #index=which(D==0)
        #index_connected<-setdiff(1:ncol(A),index)
        #A<-A[index_connected,index_connected]
        #D<-apply(abs(A),1,sum)
        D=diag(D)
        lambda=eigen(D-A,only.values = T) ## eigenvalues of the Laplacian
        ## check the number of disconnect blocks
        nb_blocks=sum(Re(lambda$values)<10^(-10)) ###numerical error
        if (nb_blocks==1){
            ### Only one connected component. Straightforward.
            ll=Re(lambda$values[which(Re(lambda$values)>10^(-12))])
            nb=-log(N)+sum(log(ll))
        }
        else{
            ### Several connected Components. Add up the number of ST in each component.
            graph=graph_from_adjacency_matrix(A, mode = "undirected",weighted=TRUE)
            index_cliques=igraph::components(graph)
            nb=0
            for (l in 1:index_cliques$no){
                selection=which(index_cliques$membership==l)
                nb<-nb+get_number_spanning_trees(A[selection,selection],adjust_disconnection=FALSE)
            }
        }
        
      
      
    }
    
    return(nb)
  }
  
}
###  --------------------------------------------------------










###  --------------------------------------------------------
ST_distance<-function(A,A_new,norm=FALSE){
  if(norm) return(abs(get_number_spanning_trees(A_new)-get_number_spanning_trees(A))/(get_number_spanning_trees(A_new,0)+get_number_spanning_trees(A,0)))
  else return(abs(get_number_spanning_trees(A_new)-get_number_spanning_trees(A)))
  
}

###  --------------------------------------------------------









##########################################################################################################
###############        Functions for checking that everything goes well     ##############################
##########################################################################################################


###  --------------------------------------------------------
### Security check nb 1

testit<-function(N=100,pow=2){
  G=erdos.renyi.game(N,0.3)
  #G=sample_pa(N, power = pow,directed=F)
  A=as_adjacency_matrix(G)
  D=sapply(1:N, FUN=function(i){
    return(sum(A[i,]))
  })
  D=diag(D)
  lambda=eigen(D-A,only.values = T)
  nb_true=log(1/N)+sum(log(lambda$values[1:(N-1)]))
  nb_test=get_number_spanning_trees(A)
  print(nb_test)
  return( abs(nb_true-nb_test)<0.0001)
}
###  --------------------------------------------------------




###  --------------------------------------------------------
### Security check nb 2:    function for visualizing the distribution of number of spanning trees #####
test_basic<-function(N,p, B=500){
    ##  Description
    ##  -------------
    ##  Function computing 500 different instances of an ER graph and evaluating the distances between graphs
    ##
    ##  INPUT:
    ##  =============================================================
    ##  N   :   Number of nodes in the graphs
    ##  p   :   probability ofconnection (ER graph)
    ##  B   :   nb of tests/trials/ different random ER graphs to generate
    ##  OUTPUT
    ##  =============================================================
    ##  nb_spanning_trees:  a B-dimensional vector where each entry is the number of spanning trees in the ith random ER graph
    
    print("Investigating the stability of the number of spanning trees:")
    print(paste("For B=",B,"trials, get number of spanning trees in a random Matrix with edge probability p=",p," and N=",N ,"nodes "))
    nb_spanning_trees<-matrix(0,B,1)
    for (i in 1:B){
        A<-generate_random_adjacency(N,p, TRUE)
        nb_spanning_trees[i]<-get_number_spanning_trees2(A)
        ## Note that all edges are weigthed equally in that case
    }
    summary(nb_spanning_trees)
    par(mfrow=c(1,2))
    plot(nb_spanning_trees)
    hist(nb_spanning_trees)
    return(nb_spanning_trees)
}
###  --------------------------------------------------------





