# CAV 2020 - Experimental Results
This repository contains the benchmarks and results for the CAV 2020 paper titled _"Verification of Quantitative Hyperproperties Using Trace Enumeration Relations"_

The models and the proof scripts are implemented in [Uclid5](https://github.com/uclid-org/uclid). Please refer to [this repository](https://github.com/uclid-org/uclid) for installation instructions and setting up the environment. 

Make sure that uclid5 is installed successfully before continuing. 

To test the environment type ```uclid``` on terminal that should produce the following output:

```
$ uclid

Error: Missing argument <file> ...
uclid 0.9.5
Usage: uclid [options] <file> ...

  -m, --main <Module>      Name of the main module.
  -s, --solver <Cmd>       External SMT solver binary.
  -y, --synthesizer <Cmd>  Command line to invoke SyGuS synthesizer.
  -Y, --synthesizer-run-directory <Dir>
                           Run directory for synthesizer.
  -g, --smt-file-generation <value>
                           File prefix to generate smt files for each assertion.
  -X, --exception-stack-trace
                           Print exception stack trace.
  -f, --sygus-format       Generate the standard SyGuS format.
  -c, --sygus-type-convert
                           Enable EnumType conversion in synthesis.
  -e, --enum-to-numeric    Enable conversion from EnumType to NumericType.
  -t, --test-fixedpoint    Test fixed point
  <file> ...               List of files to analyze.
```

## 1. Overview of the benchmarks
In this work we studied 5 systems with varying complexity. 

1. [Electronic Purse](./Models/electronic_purse) - A fixed amount is debited from an account until the balance is insufficient.
2. [Password Checker](./Models/password_checker) - Checks the user entered password against a _secret_ password.
3. [F-Y Array Shuffle](./Models/array_shuffle) - A variant of Fisher-Yates shuffle.
4. [ZK Hats](./Models/hat_protocol) - Interactive zero knowledge protocol where a prover with two hats convinces a color-blind verifier that the hats are of different colors.
5. [Path ORAM](./Models/pathORAM) - A model of path ORAM introduced by Stefanov et.al. in CCS'13.

For a detailed discussion of the benchmarks, refer to the [paper](https://arxiv.org/abs/2005.04606). 

### Folder Organization:
The Artifacts folder (current folder) contains the following items:

1. **Models/** - This folder contains the models of all the benchmarks in their respective folder.
2. **Readme.md** - The readme file with general descriptiona and desribing the details for running the experiments.
3. **generate_statistics.sh** - A bash script to generate the final experimental statistics.


Each of the 5 benchmarks reside in their respective folder inside the _Models/_ folder. Further each benchmark folder contain 3 files:

- **model.ucl** - Contains the model of the system.
- **enumeration.ucl** - Contains the enumerations and proof for the system.
- **counting.*** - Contains the counting of the solutions.

The model.ucl and enumeration.ucl files contains uclid5 modules as entry points for executing the files, and need to specified while executions. We discuss how to run the experiments in the next section.

- The main module name in *model.ucl* is _same as the folder name_ of the benchmark. E.g. For Path ORAM, residing in the folder named **pathoram**, the main module in model.ucl file is named - *pathoram*.
- The main module in enumeration.ucl file is named - *enumeration*.

## 2. Running experiments
As the folder structure and organization of the modules are same for all the  benchmarks, the steps presented here can be used for the execution of all the benchmarks.

To verify the models and the enumeration proofs follow the following steps. 

1. ```cd benchmark_name``` to enter the directory of the benchmark.
2. To verify the model: ```uclid -m benchmark_name model.ucl```
3. To verify the enumeration: ```uclid -m enumeration model.ucl enumeration.ucl```
4. To verify counting: ```uclid counting.ucl```

### Example execution for Path ORAM.
For Path ORAM, the counting module is written in [Dafny](https://www.microsoft.com/en-us/research/project/dafny-a-language-and-program-verifier-for-functional-correctness/). Please refer to [this link](https://github.com/dafny-lang/dafny/wiki/INSTALL) for installation instructions.

 ```	
$ cd pathoram
$ ls
	counting.dfy  enumeration.ucl  model.ucl
$ uclid -m pathoram model.ucl
	Successfully parsed 2 and instantiated 1 module(s).
	
	  VERIFYING PROCEDURES
	  ====================
	
	[Verifying] Stash initialization : initialize_stash
	---------------------------------------------------
	5 assertions passed.
	0 assertions failed.
	0 assertions indeterminate.
	
	[Verifying] Position Map Remap : pmap_remap
	-------------------------------------------
	3 assertions passed.
	0 assertions failed.
	0 assertions indeterminate.
	
	[Verifying] Reading to Stash from ORAM : read_to_stash
	------------------------------------------------------
	20 assertions passed.
	0 assertions failed.
	0 assertions indeterminate.
	
	[Verifying] Writing form Stash to ORAM : write_to_oram
	------------------------------------------------------
	12 assertions passed.
	0 assertions failed.
	0 assertions indeterminate.
	
	[Verifying] Organize Stash : organize_stash
	-------------------------------------------
	22 assertions passed.
	0 assertions failed.
	0 assertions indeterminate.
	
	[Verifying] ORAM Access : oram_access
	-------------------------------------
	40 assertions passed.
	0 assertions failed.
	0 assertions indeterminate.
	
	==========================================
	       PROCEDURE VERIFICATION ENDED       
	==========================================
	
	36 assertions passed.
	0 assertions failed.
	0 assertions indeterminate.
	Finished execution for module: pathoram.
	
$ uclid -m enumeration model.ucl enumeration.ucl
	Successfully parsed 3 and instantiated 1 module(s).
	138 assertions passed.
	0 assertions failed.
	0 assertions indeterminate.
	Finished execution for module: enumeration.
	
$ dafny counting.dfy
	Dafny program verifier version 1.9.7.30401, Copyright (c) 2003-2016, Microsoft.

	Dafny program verifier finished with 11 verified, 0 errors

 ```

## 3. Experimental Results

To generate the overall statistics of the expermimental evaluation, run:

```
$ ./generate_statistics.sh
```

The execution time reported in the second table is averaged over 10 runs for each benchmarks - one by one. This is also the reason the second table takes a couple of minutes to generate.

The number of runs is contolled by the following constant:

```
NUM_EXP=10
```
on line 3 of the file `generate_statistics.sh`. Modify the file to increase or decrease the number of repetitions. (`vim` is included as an editor in the image).

We present the overview of experimental results here. We refer the reader to the text of the paper for a detailed discussion of the experimental results.

| Benchmark         | Property Proven               | Model LoC | Proof LoC | Num Annotations | Verification Time |
|-------------------|-------------------------------|-----------|-----------|-----------------|-------------------|
| Electronic Purse  | Deniability                   | 46        | 93        | 9               | 3.92s                |
| Password Checker  | Quantitative non-interference | 59        | 100       | 10              | 4.69s                |
| F-Y Array Shuffle | Quantitative information flow | 86        | 195       | 96              | 7.38s                |
| ZK Hats           | Soundness                     | 91        | 191       | 36              | 6.34s                |
| Path ORAM         | Deniability                   | 587       | 209       | 142             | 9.75s               |

The experiments were conducted on an Intel(R) Core(TM) i7-4770U CPU @ 3.40GHz with 8 cores and 32 GB of RAM.


## 4. Docker Image

For ease of testing and experimenting we provide [here](https://cse.iitk.ac.in/users/ssahai/artifacts/hyperproperty.tar) a docker image contating the above models as well. Please follow the instructions below to reproduce the experimental results using docker.


### 4.1 Host Platform:

The image boots with the Ubuntu 18.04 as the underlying operating system and contains the `uclid5` binary and corresponding dependencies pre-installed. 
It also contains models for all the benchmarks in the Artifacts folder, which we will dicuss in the folder structure section.

The host platform details for preparing and testing the docker image is as follows:

- __OS__&nbsp;&nbsp;&nbsp;&nbsp;    : Ubuntu 18.04 LTS
- __Arch__&nbsp;&nbsp; : x86_64 
- __RAM__  &nbsp; : 32GB
- __CPU__ &nbsp;  : Intel(R) Core(TM) i7-4770 CPU @ 3.40GHz
- __Cores__ : 8

### 4.2 Booting the image:

1. Download the tar file of the image from [this link](https://cse.iitk.ac.in/users/ssahai/artifacts/hyperproperty.tar).
2. Ensure that the testing environment has docker installed. 
3. Then load the image using: `docker load -i hyperproperty.tar`
4. To run the image use: `docker run --rm -ti ssahai/ae:1.0 /bin/bash`

### 4.3 Folder organization:

The artifacts are present in the home folder of the container: `/root/Artifacts`. The folder contains the following items:

1. __Models__ - This folder contains the models of all the benchmarks in their respective folder.
2. __deniability.pdf__ - The pdf file of the paper. However, we recommend the following [link](https://arxiv.org/abs/2005.04606) for the most updated version of the paper.
3. __README.pdf__ - The readme file with general description and desribing the details for running the experiments. _(It's the pdf version of the readme you are reading right now!)_
4. __generate_statistics.sh__ - A bash script to generate the final experimental statistics.

For quick evaluation just execute the bash file: `./generate_statistics.sh`

For individual benchmark and other details, follow the instructions above.


__REMARK:__ _We would like to make a note that the timings of the above experiments might depend on the resources allocated to the docker container. Please refer the [docker documentation](https://docs.docker.com/config/containers/resource_constraints/) for setting the resouces via runtime options._


