(() => {
  const sidebar = document.getElementById('docs-sidebar');
  const menu = document.getElementById('docs-menu');

  function setMenuOpen(open) {
    sidebar.classList.toggle('shift', open);
    menu.setAttribute('aria-expanded', String(open));
  }

  menu.addEventListener('click', () => setMenuOpen(menu.getAttribute('aria-expanded') === 'false'));
  document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && menu.getAttribute('aria-expanded') === 'true') {
      setMenuOpen(false);
      menu.focus();
    }
  });

  sidebar.addEventListener('click', event => {
    if (event.target.closest('a')) setMenuOpen(false);
  });
  const currentPage = sidebar.querySelector('.maintoc a.current');
  if (currentPage) currentPage.setAttribute('aria-current', 'page');

  const headings = [...document.querySelectorAll('.main-content > h2[id]')];
  if (headings.length > 1) {
    const outline = document.createElement('nav');
    outline.className = 'docs-outline';
    outline.setAttribute('aria-label', 'On this page');
    const label = document.createElement('strong');
    label.textContent = 'On this page';
    outline.append(label);
    const links = headings.map(heading => {
      const link = document.createElement('a');
      link.textContent = heading.textContent;
      link.href = '#' + encodeURIComponent(heading.id);
      outline.append(link);
      return link;
    });
    document.querySelector('.maincontentouter').append(outline);

    let activeLink;
    let updatePending = false;

    function updateOutline() {
      updatePending = false;
      const viewport = document.documentElement;
      const maxScroll = viewport.scrollHeight - viewport.clientHeight;
      let currentIndex = -1;

      if (maxScroll > 1 && window.scrollY >= maxScroll - 1) {
        // The last heading may never reach the activation line on a short section.
        currentIndex = headings.length - 1;
      } else {
        const activationLine = Math.min(96, viewport.clientHeight / 4);
        for (let index = 0; index < headings.length; index++) {
          if (headings[index].getBoundingClientRect().top > activationLine) break;
          currentIndex = index;
        }
      }

      const currentLink = links[currentIndex];
      if (currentLink === activeLink) return;
      activeLink?.removeAttribute('aria-current');
      currentLink?.setAttribute('aria-current', 'location');
      activeLink = currentLink;
    }

    function scheduleOutlineUpdate() {
      if (updatePending) return;
      updatePending = true;
      window.requestAnimationFrame(updateOutline);
    }

    window.addEventListener('scroll', scheduleOutlineUpdate, { passive: true });
    window.addEventListener('resize', scheduleOutlineUpdate);
    window.addEventListener('load', scheduleOutlineUpdate);
    updateOutline();
  }
})();
