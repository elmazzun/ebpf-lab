PROJECTS := helloworld

.PHONY: all $(PROJECTS)

all: $(PROJECTS)

$(PROJECTS):
	$(MAKE) -C $@

clean:
	for dir in $(PROJECTS); do \
		$(MAKE) -C $$dir clean; \
	done
