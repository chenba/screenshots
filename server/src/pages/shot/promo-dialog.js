const React = require("react");
const PropTypes = require("prop-types");
const { Localized } = require("fluent-react/compat");

exports.PromoDialog = class PromoDialog extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    if (this.props.display) {
      return <div id="promo-dialog-panel" className="promo-panel default-color-scheme" >
        <a className="box-close" title="Close notification" onClick={this.closePanel.bind(this)}></a>
        <h4 className="title">{this.props.title}</h4>
        <p className="message">
          {this.props.message}
        </p>
        <p className="message">✨<span className="message-text">{this.props.callToAction}</span>✨</p>
      </div>;
    }
    return null;
  }

  closePanel(event) {
    this.props.promoClose();
  }
};

exports.PromoDialog.propTypes = {
  display: PropTypes.bool,
  promoClose: PropTypes.func,
  title: PropTypes.string,
  message: PropTypes.string,
  callToAction: PropTypes.string,
};
