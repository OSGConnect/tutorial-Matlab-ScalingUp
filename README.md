---
ospool:
    path: software_examples/matlab_runtime/tutorial-Matlab-ScalingUp/README.md
---

# Scaling up compute resources

Scaling up the computational resources is a big advantage for doing
certain large scale calculations on OSG. Consider the extensive
sampling for a multi-dimensional Monte Carlo integration or molecular
dynamics simulation with several initial conditions. These type of
calculations require submitting lot of jobs.

In the previous example, we submitted the job to a single worker
machine. About a million CPU hours per day are available to OSG users
on an opportunistic basis. Learning how to scale up and control large
numbers of jobs to realize the full potential of distributed high
throughput computing on the OSG.

In this section, we will see how to scale up the calculations with
simple example. Once we understand the basic HTCondor script, it is easy
to scale up.

## Background

For this example, we will use computational methods to estimate pi. First,
we will define a square inscribed by a unit circle from which we will 
randomly sample points. The ratio of the points outside the circle to 
the points in the circle is calculated which approaches pi/4. 

This method converges extremely slowly, which makes it great for a 
CPU-intensive exercise (but bad for a real estimation!).

## Set up a Matlab Job

First, we'll need to create a working directory, you can either run 
`$ tutorial Matlab-ScalingUp` or `$ git clone https://github.com/OSGConnect/tutorial-Matlab-ScalingUp` to copy all the necessary files. Otherwise, you can create the files type the following:

    $ mkdir tutorial-Matlab-ScalingUp
    $ cd tutorial-Matlab-ScalingUp

## Matlab Script

Create an Matlab script by typing the following into a file called `mcpi.m`:
```
  % Monte Carlo method for estimating pi
  % Generate N random points in a unit square
  function[] =mcpi(N)
  x = rand(N,1); % x coordinates
  y = rand(N,1); % y coordinates
  % Count how many points are inside a unit circle
  inside = 0; % counter
  for i = 1:N % loop over points
    if x(i)^2 + y(i)^2 <= 1 % check if inside circle
        inside = inside + 1; % increment counter
    end
  end
  % Estimate pi as the ratio of points inside circle to total points
  pi_est = 4 * inside / N; % pi estimate
  % Display the result
  fprintf(pi_est);
  end
```
## Compilation 

*OSG does not have a license to use the MATLAB compiler*. On a Linux server with a MATLAB 
license, invoke the compiler `mcc`.  We turn off all graphical options (`-nodisplay`), disable Java (`-nojvm`), and instruct MATLAB to run this application as a single-threaded application (`-singleCompThread`):

    mcc -m -R -singleCompThread -R -nodisplay -R -nojvm mcpi.m

The flag `-m` means C language translation during compilation, and the flag `-R` indicates runtime options.  The compilation would produce the files: 

    `mcpi, run_mcpi.sh, mccExcludedFiles.log` and `readme.txt`

The file `mcpi` is the standalone executable. The file `run_mcpi.sh` is MATLAB generated shell script. `mccExcludedFiles.log` is the log file and `readme.txt` contains the information about the compilation process. We just need the standalone binary file `mcpi`. 
## Running standalone binary applications on OSG

To see which releases are available on OSG visit our available [containers](https://portal.osg-htc.org/documentation/htc_workloads/using_software/available-contaners-list/) page :

### Tutorial files

Let us say you have created the standalone binary `mcpi`. Transfer the file `mcpi` to your Access Point. Alternatively, you may also use the readily available files by using the `git clone` command: 

    $ git clone https://github.com/OSGConnect/tutorial-Matlab-ScalingUp # Copies input and script files to the directory tutorial-Matlab-ScalingUp.
 
This will create a directory `tutorial-Matlab-ScalingUp`. Inside the directory, you will see the following files
   
    mcpi             # compiled executable binary of hello_world.m
    mcpi.m           # matlab program
    mcpi.submit      # condor job description file
    mcpi.sh          # execution script

### Executing the MATLAB application binary

The compilation and execution environment need to the same. The file `mcpi` is a standalone binary of the matlab program `mcpi.m` which was compiled using MATLAB 2020b on a Linux platform. The Access Point and many of the worker nodes on OSG are based on Linux platform. In addition to the platform requirement, we also need to have the same MATLAB Runtime version. 

Load the MATLAB runtime for 2020b version via apptainer/singularity command.  On the terminal prompt, type

    $ apptainer shell /cvmfs/singularity.opensciencegrid.org/opensciencegrid/osgvo-matlab-runtime:R2020b

The above command sets up the environment to run the matlab/2020b runtime applications.  Now execute the binary

    $apptainer/singularity> ./mcpi 10

If you get the an output of the estimated value of pi, the binary execution is successful. Now, exit from the apptainer/singularity environment typing `exit`. Next, we see how to submit the job on a remote execute point using HTCondor.

### Job execution and submission files

Let us take a look at `mcpi.submit` file: 

    universe = vanilla                          # One OSG Connect vanilla, the preffered job universe is "vanilla"
    +SingularityImage = "/cvmfs/singularity.opensciencegrid.org/opensciencegrid/osgvo-matlab-runtime:R2020b"
    
    executable =  mcpi                
    arguments = $(Process)
    
    Output = Log/job.$(Process).out⋅            # standard output 
    Error =  Log/job.$(Process).err             # standard error
    Log =    Log/job.$(Process).log             # log information about job execution
    
    requirements = HAS_SINGULARITY == TRUE 
    queue 100                                   # Submit 100  jobs


Before we submit the job, make sure that the directory `Log` exists on the current working directory. Because HTCondor looks for `Log` directory to copy the standard output, error and log files as specified in the job description file. 

From your work directory, type

    $ mkdir -p Log

Absence of `Log` directory may send the jobs to held state. 

### Job submmision 

We submit the job using the `condor_submit` command as follows

	$ condor_submit mcpi.submit //Submit the condor job description file "mcpi.submit"

Now you have submitted an ensemble of 100 MATLAB jobs. Each job prints the value of `pi` on the standard 
output. Check the status of the submitted job,  

	$ condor_q username  # The status of the job is printed on the screen. Here, username is your login name.


## Post Process⋅

Once the jobs are completed, you can use the information in the output files 
to calculate an average of all of our computed estimates of Pi.

To see this, we can use the command:

	$ cat log/mcpi*.out* | awk '{ sum += $2; print $2"   "NR} END { print "---------------\n Grand Average = " sum/NR }'

# Key Points

- Scaling up the computational resources on OSG is crucial to taking full advantage of distributed computing.
- Changing the value of `Queue` allows the user to scale up the resources.
- `Arguments` allows you to pass parameters to a job script.
- `$(Cluster)` and `$(Process)` can be used to name log files uniquely.

# Getting Help

For assistance or questions, please email the OSG User Support team at 
<mailto:support@osg-htc.org>.
