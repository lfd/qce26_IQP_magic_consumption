.PHONY: all figures

BUILD_DIR := build
CREATE_BUILD_DIR := $(BUILD_DIR)/.create_build_dir

TEST = false


all: figures

figures: figures/absdsre_vs_djsd.pdf \
		 figures/absdsre_vs_djsd_per_gate_type.pdf \
		 figures/rel_phase_shift_sre_distr.pdf \
		 figures/rel_phase_shift_sre_zscores.pdf


$(CREATE_BUILD_DIR):
	if [ -e $(BUILD_DIR) ]; then touch $(CREATE_BUILD_DIR); else mkdir $(BUILD_DIR); touch $(CREATE_BUILD_DIR); fi


$(BUILD_DIR)/absdsre_vs_djsd.tex: figure_generators/absdsre_vs_djsd.r figure_generators/absdsre_vs_djsd.dims figure_generators/util.r $(CREATE_BUILD_DIR)
	$(eval DIMS := $(shell cat figure_generators/absdsre_vs_djsd.dims))
	cd figure_generators;\
		Rscript write_tex.r absdsre_vs_djsd.r ../out_n7.csv $(DIMS);\
		mv absdsre_vs_djsd.tex ../$(BUILD_DIR)

figures/absdsre_vs_djsd.pdf: $(BUILD_DIR)/absdsre_vs_djsd.tex
	mkdir -p figures
	latexmk -shell-escape -pdf -lualatex -output-directory=$(BUILD_DIR) -jobname=absdsre_vs_djsd $(BUILD_DIR)/absdsre_vs_djsd.tex
	mv $(BUILD_DIR)/absdsre_vs_djsd.pdf figures/	


$(BUILD_DIR)/absdsre_vs_djsd_per_gate_type.tex: figure_generators/absdsre_vs_djsd_per_gate_type.r figure_generators/absdsre_vs_djsd_per_gate_type.dims figure_generators/util.r $(CREATE_BUILD_DIR)
	$(eval DIMS := $(shell cat figure_generators/absdsre_vs_djsd_per_gate_type.dims))
	cd figure_generators;\
		Rscript write_tex.r absdsre_vs_djsd_per_gate_type.r ../out_n7.csv $(DIMS);\
		mv absdsre_vs_djsd_per_gate_type.tex ../$(BUILD_DIR)

figures/absdsre_vs_djsd_per_gate_type.pdf: $(BUILD_DIR)/absdsre_vs_djsd_per_gate_type.tex
	mkdir -p figures
	latexmk -shell-escape -pdf -lualatex -output-directory=$(BUILD_DIR) -jobname=absdsre_vs_djsd_per_gate_type $(BUILD_DIR)/absdsre_vs_djsd_per_gate_type.tex
	mv $(BUILD_DIR)/absdsre_vs_djsd_per_gate_type.pdf figures/	


$(BUILD_DIR)/rel_phase_shift_sre_distr.tex: figure_generators/rel_phase_shift_sre_distr.r figure_generators/rel_phase_shift_sre_distr.dims figure_generators/util.r $(CREATE_BUILD_DIR)
	$(eval DIMS := $(shell cat figure_generators/rel_phase_shift_sre_distr.dims))
	cd figure_generators;\
		Rscript write_tex.r rel_phase_shift_sre_distr.r ../out_phase_shift_100s_50c_n7.csv $(DIMS);\
		mv rel_phase_shift_sre_distr.tex ../$(BUILD_DIR)

figures/rel_phase_shift_sre_distr.pdf: $(BUILD_DIR)/rel_phase_shift_sre_distr.tex
	mkdir -p figures
	latexmk -shell-escape -pdf -lualatex -output-directory=$(BUILD_DIR) -jobname=rel_phase_shift_sre_distr $(BUILD_DIR)/rel_phase_shift_sre_distr.tex
	mv $(BUILD_DIR)/rel_phase_shift_sre_distr.pdf figures/	


$(BUILD_DIR)/rel_phase_shift_sre_zscores.tex: figure_generators/rel_phase_shift_sre_zscores.r figure_generators/rel_phase_shift_sre_zscores.dims figure_generators/util.r $(CREATE_BUILD_DIR)
	$(eval DIMS := $(shell cat figure_generators/rel_phase_shift_sre_zscores.dims))
	cd figure_generators;\
		Rscript write_tex.r rel_phase_shift_sre_zscores.r ../out_phase_shift_100s_50c_n7.csv $(DIMS);\
		mv rel_phase_shift_sre_zscores.tex ../$(BUILD_DIR)

figures/rel_phase_shift_sre_zscores.pdf: $(BUILD_DIR)/rel_phase_shift_sre_zscores.tex
	mkdir -p figures
	latexmk -shell-escape -pdf -lualatex -output-directory=$(BUILD_DIR) -jobname=rel_phase_shift_sre_zscores $(BUILD_DIR)/rel_phase_shift_sre_zscores.tex
	mv $(BUILD_DIR)/rel_phase_shift_sre_zscores.pdf figures/	
